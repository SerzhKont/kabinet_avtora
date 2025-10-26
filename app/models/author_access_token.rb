class AuthorAccessToken < ApplicationRecord
  belongs_to :author

  before_create :generate_token
  before_create :set_expiry

  serialize :document_ids, coder: JSON

  def expired?
    expires_at > Time.current
  end

  def documents
    Document.where(id: document_ids)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_expiry
    self.expires_at = 7.days.from_now
  end
end
