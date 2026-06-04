class CreateBusinessDaysCalculations < ActiveRecord::Migration[8.1]
  def change
    create_table :business_days_calculations do |t|
      t.string  :token,       null: false
      t.string  :mode,        null: false
      t.date    :from_date,   null: false
      t.date    :to_date
      t.integer :input_days
      t.string  :direction
      t.string  :country_code
      t.integer :result_days, null: false
      t.date    :result_date
      t.bigint  :user_id
      t.timestamps
    end

    add_index :business_days_calculations, :token, unique: true
    add_index :business_days_calculations, :user_id
    add_foreign_key :business_days_calculations, :users
  end
end
