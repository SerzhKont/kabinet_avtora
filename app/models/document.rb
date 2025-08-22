class Document < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :uploaded_by, class_name: "User"

  has_one_attached :file

  enum :status, { pending: "pending", signed: "signed", rejected: "rejected" }, default: "pending"

  validates :title, presence: true
  validates :file, presence: true
  validates :client, presence: true
  validates :uploaded_by, presence: true
  validate :client_must_be_client_role
  validate :uploaded_by_must_be_manager

  private

  def client_must_be_client_role
    errors.add(:client, "must have client role") unless client&.client?
  end

  def uploaded_by_must_be_manager
    errors.add(:uploaded_by, "must have manager role") unless uploaded_by&.manager?
  end
end
