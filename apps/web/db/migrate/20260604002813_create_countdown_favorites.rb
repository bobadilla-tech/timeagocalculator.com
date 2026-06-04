class CreateCountdownFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :countdown_favorites do |t|
      t.references :user,      null: false, foreign_key: true
      t.references :countdown, null: false, foreign_key: true
      t.timestamps
    end
    add_index :countdown_favorites, [ :user_id, :countdown_id ], unique: true
  end
end
