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

  before_validation :extract_metadata, if: -> { file.attached? }

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
end
