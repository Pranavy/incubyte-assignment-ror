# frozen_string_literal: true

require "rails_helper"

RSpec.describe TdsRule, type: :model do
  let(:valid_attributes) do
    {
      country: "IN",
      tds_rate: BigDecimal("0.1"),
      effective_from: Date.new(2024, 1, 1),
      effective_to: nil
    }
  end

  describe "validations" do
    it "is valid with allowed attributes" do
      rule = described_class.new(valid_attributes)
      expect(rule).to be_valid
    end

    it "requires country" do
      rule = described_class.new(valid_attributes.merge(country: nil))
      expect(rule).not_to be_valid
      expect(rule.errors[:country]).to include("can't be blank")
    end

    it "requires country to be an allowed key" do
      rule = described_class.new(valid_attributes.merge(country: "ZZ"))
      expect(rule).not_to be_valid
      expect(rule.errors[:country]).to be_present
    end

    it "normalizes country to uppercase" do
      rule = described_class.create!(valid_attributes.merge(country: "in"))
      expect(rule.country).to eq("IN")
    end

    it "requires tds_rate" do
      rule = described_class.new(valid_attributes.merge(tds_rate: nil))
      expect(rule).not_to be_valid
      expect(rule.errors[:tds_rate]).to be_present
    end

    it "requires tds_rate between 0 and 1 (inclusive)" do
      expect(described_class.new(valid_attributes.merge(tds_rate: -0.01))).not_to be_valid
      expect(described_class.new(valid_attributes.merge(tds_rate: 1.01))).not_to be_valid
      expect(described_class.new(valid_attributes.merge(tds_rate: 0))).to be_valid
      expect(described_class.new(valid_attributes.merge(tds_rate: 1))).to be_valid
    end

    it "requires effective_from" do
      rule = described_class.new(valid_attributes.merge(effective_from: nil))
      expect(rule).not_to be_valid
      expect(rule.errors[:effective_from]).to include("can't be blank")
    end

    it "requires effective_to to be strictly after effective_from when present" do
      rule = described_class.new(
        valid_attributes.merge(
          effective_from: Date.new(2024, 6, 1),
          effective_to: Date.new(2024, 6, 1)
        )
      )
      expect(rule).not_to be_valid
      expect(rule.errors[:effective_to]).to be_present
    end

    it "allows effective_to to be nil (open-ended)" do
      rule = described_class.new(valid_attributes.merge(effective_to: nil))
      expect(rule).to be_valid
    end

    it "enforces uniqueness of effective_from scoped to country" do
      described_class.create!(valid_attributes)
      duplicate = described_class.new(valid_attributes)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:effective_from]).to be_present
    end

    it "does not allow overlapping date ranges for the same country" do
      described_class.create!(
        valid_attributes.merge(
          effective_from: Date.new(2024, 1, 1),
          effective_to: Date.new(2024, 12, 31)
        )
      )

      overlap = described_class.new(
        valid_attributes.merge(
          effective_from: Date.new(2024, 6, 1),
          effective_to: Date.new(2025, 6, 30)
        )
      )
      expect(overlap).not_to be_valid
      expect(overlap.errors[:base]).to be_present
    end

    it "allows adjacent non-overlapping ranges for the same country" do
      described_class.create!(
        valid_attributes.merge(
          effective_from: Date.new(2024, 1, 1),
          effective_to: Date.new(2024, 12, 31)
        )
      )

      next_rule = described_class.new(
        valid_attributes.merge(
          effective_from: Date.new(2025, 1, 1),
          effective_to: nil
        )
      )
      expect(next_rule).to be_valid
      expect(next_rule.save).to be true
    end

    it "allows the same effective_from for different countries" do
      described_class.create!(valid_attributes)
      other = described_class.new(
        valid_attributes.merge(country: "US")
      )
      expect(other).to be_valid
    end
  end

  describe ".effective_tds_rate_for_country" do
    let(:mid_2024) { Date.new(2024, 6, 15) }

    it "returns the database rate when a rule applies on that date" do
      described_class.create!(
        country: "IN",
        tds_rate: BigDecimal("0.08"),
        effective_from: Date.new(2024, 1, 1),
        effective_to: nil
      )
      expect(described_class.effective_tds_rate_for_country("IN", as_of: mid_2024)).to eq(BigDecimal("0.08"))
    end

    it "returns default 10% for IN when no rule covers that date" do
      described_class.create!(
        country: "IN",
        tds_rate: BigDecimal("0.08"),
        effective_from: Date.new(2025, 1, 1),
        effective_to: nil
      )
      expect(described_class.effective_tds_rate_for_country("IN", as_of: mid_2024)).to eq(BigDecimal("0.10"))
    end

    it "returns default 12% for US when no rule exists" do
      expect(described_class.effective_tds_rate_for_country("US", as_of: mid_2024)).to eq(BigDecimal("0.12"))
    end

    it "returns 0 for other countries when no rule exists" do
      expect(described_class.effective_tds_rate_for_country("DE", as_of: mid_2024)).to eq(BigDecimal("0"))
    end
  end
end
