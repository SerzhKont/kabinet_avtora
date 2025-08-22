class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { admin: "admin", manager: "manager", client: "client" }, default: "client"

  validates :email_address, presence: true, uniqueness: true
  validates :client_code, presence: true, uniqueness: true, if: :client?
  validates :name, presence: true, if: :client?

  has_many :uploaded_documents, class_name: "Document", foreign_key: "uploaded_by_id", dependent: :destroy
  has_many :client_documents, class_name: "Document", foreign_key: "client_id", dependent: :destroy
end
