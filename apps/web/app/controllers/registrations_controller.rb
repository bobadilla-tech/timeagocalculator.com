class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    assign_username(@user)
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Account created! Welcome."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end

  def assign_username(user)
    return if user.email_address.blank?
    base = user.email_address.split("@").first.gsub(/[^a-z0-9_]/, "").first(20)
    base = "user" if base.blank?
    candidate = base
    n = 1
    while User.exists?(username: candidate)
      candidate = "#{base}#{n}"
      n += 1
    end
    user.username = candidate
  end
end
