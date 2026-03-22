# frozen_string_literal: true

class Employee < ApplicationRecord
  extend FilterByCriteria

  FILTER_SORTABLE_COLUMNS = %w[created_at updated_at last_name first_name salary country job_title_id].freeze

  belongs_to :job_title

  before_validation :normalize_country

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :country, presence: true, inclusion: { in: Countries::KEYS, message: "is not an allowed country code" }
  validates :salary, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :filter_by_country, lambda { |country|
    where(country: country.to_s.upcase)
  }

  scope :filter_by_job_title_id, lambda { |job_title_id|
    where(job_title_id: job_title_id)
  }

  scope :filter_by_search, lambda { |term|
    q = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where("employees.first_name LIKE ? OR employees.last_name LIKE ?", q, q)
  }

  def self.filter_sortable_columns
    FILTER_SORTABLE_COLUMNS
  end

  def self.default_build_criteria_order(relation)
    relation.order(created_at: :desc, id: :desc)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def normalize_country
    self.country = country.to_s.upcase.presence
  end
end
