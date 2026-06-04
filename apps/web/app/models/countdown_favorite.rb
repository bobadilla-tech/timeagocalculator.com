class CountdownFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :countdown

  validates :user_id, uniqueness: { scope: :countdown_id }
end
