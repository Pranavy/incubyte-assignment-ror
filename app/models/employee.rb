# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :job_title

  before_validation :normalize_country

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :country, presence: true, inclusion: { in: Countries::KEYS, message: "is not an allowed country code" }
  validates :salary, presence: true, numericality: { greater_than_or_equal_to: 0 }


  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def normalize_country
    self.country = country.to_s.upcase.presence
  end
end
