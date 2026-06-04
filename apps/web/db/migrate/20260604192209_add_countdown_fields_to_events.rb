class AddCountdownFieldsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :image_url, :string
    add_column :events, :ends_at, :datetime
    add_column :events, :featured, :boolean, default: false, null: false
    add_column :events, :recurrence, :string, default: "one_time", null: false
    add_column :events, :external_id, :string
    add_column :events, :country_codes, :text, array: true, default: []

    add_index :events, :external_id
    add_index :events, :country_codes, using: :gin
    add_index :events, :starts_at
    add_index :events, [ :published, :starts_at ]
  end
end
