class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :uploaded_documents, class_name: "Document", foreign_key: :uploaded_by_id

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { admin: "admin", manager: "manager" }, default: "manager"

  validates :email_address, presence: true, uniqueness: true
  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password
end
