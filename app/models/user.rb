class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :documents_as_client, class_name: "Document", foreign_key: :client_id
  has_many :uploaded_documents, class_name: "Document", foreign_key: :uploaded_by_id

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { admin: "admin", manager: "manager", client: "client" }, default: "client"

  validates :email_address, presence: true, uniqueness: true
  validates :client_code, presence: true, uniqueness: true, if: :client?
  validates :client_code, absence: true, unless: :client?
  validates :name, presence: true, if: :client?
  validates :password, presence: true, length: { minimum: 6 }, if: :password
end
