class DocumentGroup < ApplicationRecord
  belongs_to :author

  serialize :document_ids, coder: JSON

  before_create :generate_token
  before_create :set_expiration

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :document_ids, presence: true

  def documents
    Document.where(id: document_ids)
  end

  def valid_link?
    self.expires_at > Time.current
  end

  def self.find_valid(token)
    group = find_by(token: token)
    group&.valid_link? ? group : nil
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end
end
