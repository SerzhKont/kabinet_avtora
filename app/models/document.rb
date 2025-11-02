class Document < ApplicationRecord
  has_paper_trail
  belongs_to :author, optional: true
  belongs_to :uploaded_by, class_name: "User"

  has_one_attached :file

  enum :status, { pending: "pending", signed: "signed", rejected: "rejected", linked: "linked", unlinked: "unlinked" }

  STATUS_LABELS = {
    "linked"   => "Новий",
    "pending"  => "На підписанні",
    "signed"   => "Підписано",
    "rejected" => "Відхилено",
    "unlinked" => "Автор не знайдений"
  }.freeze

  def status_label
    STATUS_LABELS[status] || status.humanize
  end

  before_validation :extract_metadata, if: -> { file.attached? && new_record? }
  validates :title, presence: true
  validates :file, presence: true, on: :create
  validates :uploaded_by, presence: true
  validate :check_file_size

  before_save :update_extracted_code_from_author
  # before_save :generate_file_hash, if: -> { file.attached? && file.changed? }

  # Allow searching/sorting on these attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[title content created_at status extracted_code signed_at sent_for_signature_at]
  end

  # Allow searching/sorting on associations (if any)
  def self.ransackable_associations(auth_object = nil)
    %w[author uploaded_by]
  end

  private

  def update_extracted_code_from_author
    self.extracted_code = author&.code.to_s
  end

  def extract_metadata
    filename = file.filename.to_s

    self.title = File.basename(filename) if title.blank?

    code = filename[0, 10]
    author = Author.find_by(code: code)
    self.extracted_code = code if code.present?

    if author
      self.author = author
      self.status ||= "linked"
    else
      self.status ||= "unlinked"
      Rails.logger.warn("Author not found for code: #{code}")
    end
  end

  # def generate_file_hash
  #   content = file.download
  #   # Пока SHA256 (встроенный), для ГОСТ добавим gem позже
  #   self.file_hash = Base64.encode64(Digest::SHA256.digest(content)).chomp
  # end

  def check_file_size
    if file.attached? && file.blob.byte_size > 5.megabytes
      errors.add(:file, "размер файла превышает допустимый лимит (5 МБ)")
    end
  end
end
