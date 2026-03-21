class CreateJobTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :job_titles do |t|
      t.string :title, null: false

      t.timestamps
    end
    add_index :job_titles, :title, unique: true
  end
end
