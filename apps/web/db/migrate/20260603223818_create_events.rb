class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.datetime :starts_at, null: false
      t.string :category
      t.string :source
      t.text :description
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :events, :slug, unique: true
  end
end
