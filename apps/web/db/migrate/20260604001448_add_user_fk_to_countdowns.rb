class AddUserFkToCountdowns < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :countdowns, :users, column: :user_id
  end
end
