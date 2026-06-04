class AddPublishedToCountdowns < ActiveRecord::Migration[8.1]
  def change
    add_column :countdowns, :published, :boolean, null: false, default: false
  end
end
