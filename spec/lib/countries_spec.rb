# frozen_string_literal: true

require "rails_helper"

RSpec.describe Countries do
  describe "ALL" do
    it "lists known countries with keys and labels" do
      keys = described_class::ALL.map(&:key)
      expect(keys).to include("IN", "US", "GB", "DE", "AU")
      india = described_class::ALL.find { |e| e.key == "IN" }
      expect(india.label).to eq("India")
    end
  end

  describe ".valid_key?" do
    it "returns true for allowed keys (case-insensitive)" do
      expect(described_class.valid_key?("IN")).to be true
      expect(described_class.valid_key?("in")).to be true
    end

    it "returns false for unknown keys" do
      expect(described_class.valid_key?("XX")).to be false
    end
  end

  describe ".label_for" do
    it "returns the label for a key" do
      expect(described_class.label_for("US")).to eq("United States")
    end

    it "returns nil for unknown keys" do
      expect(described_class.label_for("ZZ")).to be_nil
    end
  end

  describe ".options_for_select" do
    it "returns label/key pairs sorted by label" do
      pairs = described_class.options_for_select
      expect(pairs).to all(be_a(Array))
      expect(pairs.map(&:last)).to match_array(described_class::KEYS)
      labels = pairs.map(&:first)
      expect(labels).to eq(labels.sort)
    end
  end
end
