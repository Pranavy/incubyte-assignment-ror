# frozen_string_literal: true

class CreateTdsRules < ActiveRecord::Migration[8.1]
  def change
    create_table :tds_rules do |t|
      t.string :country, null: false
      t.decimal :tds_rate, precision: 7, scale: 4, null: false
      t.date :effective_from, null: false
      t.date :effective_to

      t.timestamps null: false
    end

    add_index :tds_rules, %i[country effective_from], unique: true
    add_index :tds_rules, :country
  end
end
