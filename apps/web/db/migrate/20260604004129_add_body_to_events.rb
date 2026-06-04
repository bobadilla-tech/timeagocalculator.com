class AddBodyToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :body, :text
  end
end
