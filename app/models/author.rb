class Author < ApplicationRecord
  validates :code, presence: true, uniqueness: true, length: { is: 10 }, numericality: { only_integer: true }
  validates :name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_many :documents, dependent: :destroy
  has_many :document_groups, dependent: :destroy

  def self.find_by_code_or_name(query)
    where("code::text ILIKE ? OR name ILIKE ?", "%#{query}%", "%#{query}%")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[ code email_address name ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[documents]
  end
end
