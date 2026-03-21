class JobTitle < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :title, presence: true, uniqueness: true
end
