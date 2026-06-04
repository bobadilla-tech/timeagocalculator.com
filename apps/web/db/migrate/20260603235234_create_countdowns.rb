class CreateCountdowns < ActiveRecord::Migration[8.1]
  def change
    create_table :countdowns do |t|
      t.string   :title,           null: false
      t.string   :token,           null: false
      t.datetime :target_date,     null: false
      t.text     :description
      t.boolean  :is_public,       null: false, default: true
      t.string   :password_digest
      t.integer  :user_id

      t.timestamps
    end

    add_index :countdowns, :token, unique: true
  end
end
