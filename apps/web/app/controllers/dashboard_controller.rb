class DashboardController < ApplicationController
  include Pagy::Backend

  before_action :require_user!

  def index
    @pagy_mine, @my_countdowns = pagy(
      Current.user.countdowns.order(created_at: :desc),
      limit: 20
    )
    @pagy_fav, @favorited = pagy(
      Current.user.favorited_countdowns
             .includes(:countdown_favorites)
             .order("countdown_favorites.created_at desc"),
      limit: 20
    )
  end

  private

  def require_user!
    request_authentication unless authenticated?
  end
end
