class AddLockedToCountdowns < ActiveRecord::Migration[8.1]
  def change
    add_column :countdowns, :locked, :boolean, null: false, default: false
  end
end
