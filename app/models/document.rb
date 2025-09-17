class Document < ApplicationRecord
  has_paper_trail
  belongs_to :author, optional: true
  belongs_to :uploaded_by, class_name: "User"

  has_one_attached :file

  enum :status, { pending: "pending", signed: "signed", rejected: "rejected", linked: "linked", unlinked: "unlinked" }, default: "linked"

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

  validates :title, presence: true
  validates :file, presence: true
  validates :uploaded_by, presence: true
  validate :check_file_size

  before_validation :extract_metadata, if: -> { file.attached? }
  # before_save :generate_file_hash, if: -> { file.attached? && file.changed? }

  # Allow searching/sorting on these attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[title content created_at status extracted_code signed_at]
  end

  # Allow searching/sorting on associations (if any)
  def self.ransackable_associations(auth_object = nil)
    %w[author uploaded_by]
  end

  private

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
