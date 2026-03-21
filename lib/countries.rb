# frozen_string_literal: true

# Canonical country keys (ISO 3166-1 alpha-2) and display labels for forms and validation.
module Countries
  Entry = Struct.new(:key, :label, keyword_init: true)

  ALL = [
    Entry.new(key: "IN", label: "India"),
    Entry.new(key: "US", label: "United States"),
    Entry.new(key: "GB", label: "United Kingdom"),
    Entry.new(key: "DE", label: "Germany"),
    Entry.new(key: "AU", label: "Australia")
  ].freeze

  KEYS = ALL.map(&:key).freeze

  module_function

  def valid_key?(key)
    KEYS.include?(key.to_s.upcase)
  end

  def label_for(key)
    entry = ALL.find { |e| e.key == key.to_s.upcase }
    entry&.label
  end

  # Array of [label, key] for Rails select helpers (sorted by label)
  def options_for_select
    ALL.sort_by(&:label).map { |e| [ e.label, e.key ] }
  end
end
