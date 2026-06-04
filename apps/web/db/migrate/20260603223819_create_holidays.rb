class CreateHolidays < ActiveRecord::Migration[8.1]
  def change
    create_table :holidays do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :country, null: false, default: "US"
      t.integer :month, null: false
      t.integer :day, null: false
      t.text :description
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :holidays, :slug, unique: true
  end
end
