class DashboardController < ApplicationController
  include Pagy::Method

  before_action :require_user!

  def index
    @pagy_mine, @my_countdowns = pagy(
      :offset,
      Current.user.countdowns.order(created_at: :desc),
      limit: 20
    )
    @pagy_fav, @favorited = pagy(
      :offset,
      Current.user.favorited_countdowns
             .includes(:countdown_favorites)
             .order("countdown_favorites.created_at desc"),
      limit: 20
    )
    @calculations = Current.user.business_days_calculations.order(created_at: :desc).limit(50)
  end

  private

  def require_user!
    request_authentication unless authenticated?
  end
end
