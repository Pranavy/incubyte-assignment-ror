# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :country, null: false
      t.decimal :salary, precision: 12, scale: 2, null: false
      t.references :job_title, null: false, foreign_key: true

      t.timestamps null: false
    end
  end
end
