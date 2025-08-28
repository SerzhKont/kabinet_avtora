class Document < ApplicationRecord
  has_paper_trail
  belongs_to :client, class_name: "User", optional: true
  belongs_to :uploaded_by, class_name: "User"

  has_one_attached :file

  enum :status, { just_uploaded: "Новий", pending: "На підписанні", signed: "Підписано"  }, default: :just_uploaded

  validates :title, presence: true
  validates :file, presence: true
  validates :uploaded_by, presence: true
  validate :client_must_be_client_role
  validate :uploaded_by_must_be_manager_or_admin

  before_validation :extract_metadata, if: -> { file.attached? }

  private

  def client_must_be_client_role
    errors.add(:client, "must have client role") unless client&.client?
  end

  def uploaded_by_must_be_manager_or_admin
    errors.add(:uploaded_by, "must have manager or admin role") unless uploaded_by&.manager? || uploaded_by&.admin?
  end

  def extract_metadata
    filename = file.filename.to_s

    # Название документа = имя файла без расширения
    self.title = File.basename(filename, ".*") if title.blank?

    # Код клиента = первые 8 символов
    client_code = filename[0, 8]
    user = User.find_by(client_code: client_code, role: "client")

    if user
      self.client = user
      self.status ||= "linked"
    else
      self.status ||= "unlinked"
    end
  end
end
