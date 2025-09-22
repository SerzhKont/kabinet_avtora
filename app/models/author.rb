class Author < ApplicationRecord
  has_secure_token :access_token
  validates :code, presence: true, uniqueness: true, length: { is: 10 }, numericality: { only_integer: true }
  validates :name, presence: true
  has_many :documents, dependent: :destroy

  def self.find_by_code_or_name(query)
    where("code::text ILIKE ? OR name ILIKE ?", "%#{query}%", "%#{query}%")
  end

  def regenerate_access_token_with_expiry(days = 7)
    regenerate_access_token  # Из has_secure_token
    update!(access_token_expires_at: days.days.from_now)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[ code email_address name ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[documents]
  end
end
