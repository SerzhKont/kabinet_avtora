class Author < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  has_many :documens
end
