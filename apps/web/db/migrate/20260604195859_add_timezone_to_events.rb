class AddTimezoneToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :timezone, :string
  end
end
