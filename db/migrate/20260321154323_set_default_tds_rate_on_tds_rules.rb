# frozen_string_literal: true

class SetDefaultTdsRateOnTdsRules < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tds_rules, :tds_rate, from: nil, to: 0.0
  end
end
