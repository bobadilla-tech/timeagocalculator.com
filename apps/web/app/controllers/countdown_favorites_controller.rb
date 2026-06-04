class CountdownFavoritesController < ApplicationController
  before_action :set_countdown
  before_action :require_user!

  def create
    Current.user.countdown_favorites.find_or_create_by!(countdown: @countdown)
    redirect_to shared_countdown_path(@countdown.token)
  end

  def destroy
    Current.user.countdown_favorites.find_by(countdown: @countdown)&.destroy
    redirect_to shared_countdown_path(@countdown.token)
  end

  private

  def set_countdown
    @countdown = Countdown.find_by!(token: params[:token])
  end

  def require_user!
    request_authentication unless authenticated?
  end
end
