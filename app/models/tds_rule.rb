# frozen_string_literal: true

class TdsRule < ApplicationRecord
  OPEN_END = Date.new(9999, 12, 31)

  before_validation :normalize_country

  validates :country, presence: true, inclusion: { in: Countries::KEYS, message: "is not an allowed country code" }
  validates :tds_rate, presence: true,
                       numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :effective_from, presence: true
  validates :effective_from, uniqueness: { scope: :country }
  validate :effective_to_after_effective_from
  validate :no_overlapping_country_ranges

  private

  def normalize_country
    self.country = country.to_s.upcase.presence
  end

  def effective_to_after_effective_from
    return if effective_to.blank?
    return if effective_to > effective_from

    errors.add(:effective_to, "must be after effective_from")
  end

  def no_overlapping_country_ranges
    return if country.blank? || effective_from.blank?

    siblings = self.class.where(country: country).where.not(id: id || 0)
    siblings.find_each do |other|
      next unless intervals_overlap?(effective_from, effective_to, other.effective_from, other.effective_to)

      errors.add(:base, "Date range overlaps an existing TDS rule for this country")
      break
    end
  end

  def intervals_overlap?(from_a, to_a, from_b, to_b)
    end_a = to_a || OPEN_END
    end_b = to_b || OPEN_END
    [ from_a, from_b ].max <= [ end_a, end_b ].min
  end
end
