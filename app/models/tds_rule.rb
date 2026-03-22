# frozen_string_literal: true

class TdsRule < ApplicationRecord
  OPEN_END = Date.new(9999, 12, 31)

  # When no row applies for (country, as_of), these defaults apply for net salary (gross × (1 − rate)).
  DEFAULT_TDS_RATE_BY_COUNTRY = {
    "IN" => BigDecimal("0.10"),
    "US" => BigDecimal("0.12")
  }.freeze

  before_validation :normalize_country

  validates :country, presence: true, inclusion: { in: Countries::KEYS, message: "is not an allowed country code" }
  validates :tds_rate, presence: true,
                       numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :effective_from, presence: true
  validates :effective_from, uniqueness: { scope: :country }
  validate :effective_to_after_effective_from
  validate :no_overlapping_country_ranges

  # Rate in effect for +country+ on +as_of+ (0..1). Uses the matching DB rule if any; otherwise IN 10%, US 12%, else 0%.
  def self.effective_tds_rate_for_country(country, as_of: Date.current)
    code = country.to_s.upcase
    return default_tds_rate_for_country(code) unless Countries.valid_key?(code)

    rule = applicable_rule_for_country_on(code, as_of)
    rule ? rule.tds_rate : default_tds_rate_for_country(code)
  end

  def self.default_tds_rate_for_country(country_code)
    DEFAULT_TDS_RATE_BY_COUNTRY[country_code.to_s.upcase] || BigDecimal("0")
  end

  def self.applicable_rule_for_country_on(country_code, as_of)
    where(country: country_code)
      .where("effective_from <= ?", as_of)
      .where("effective_to IS NULL OR effective_to >= ?", as_of)
      .order(effective_from: :desc)
      .first
  end

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
