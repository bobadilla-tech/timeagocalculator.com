class CountdownsController < ApplicationController
  include SeoMetaTaggable

  before_action :set_countdown, only: [ :show, :unlock, :authenticate ]

  def new
    @countdown = Countdown.new(is_public: true)
    set_meta_tags(
      title: "Create a Countdown Timer — Share with Anyone",
      description: "Create a free custom countdown to any date. Get a shareable link instantly. No account required.",
      canonical: new_countdown_url
    )
  end

  def create
    @countdown = Countdown.new(countdown_params)
    if @countdown.save
      redirect_to shared_countdown_path(@countdown.token)
    else
      set_meta_tags(title: "Create a Countdown Timer")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    unless @countdown.is_public? || authenticated?
      redirect_to unlock_countdown_path(@countdown.token) and return
    end

    @result = @countdown.time_until
    set_meta_tags(
      title: "#{@countdown.title} — Countdown Timer",
      description: countdown_description(@countdown, @result),
      canonical: shared_countdown_url(@countdown.token),
      og: { title: @countdown.title, description: countdown_description(@countdown, @result) }
    )
  end

  def unlock
    # render unlock form
  end

  def authenticate
    if @countdown.authenticate(params[:password].to_s)
      session["countdown_auth_#{@countdown.token}"] = true
      redirect_to shared_countdown_path(@countdown.token)
    else
      @error = "Incorrect password."
      render :unlock, status: :unprocessable_entity
    end
  end

  private

  def set_countdown
    @countdown = Countdown.find_by!(token: params[:token])
  end

  def authenticated?
    session["countdown_auth_#{@countdown.token}"] == true
  end

  def countdown_params
    params.expect(countdown: [ :title, :target_date, :description, :is_public,
                                :password, :password_confirmation ])
  end

  def countdown_description(countdown, result)
    return "Countdown to #{countdown.title}." if result.is_past
    parts = []
    parts << "#{result.years} years" if result.years > 0
    parts << "#{result.months} months" if result.months > 0
    parts << "#{result.days} days" if result.days > 0
    "#{parts.to_sentence} until #{countdown.title}."
  end
end
