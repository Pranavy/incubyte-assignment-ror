class JobTitle < ApplicationRecord
  validates :title, presence: true, uniqueness: true
end
