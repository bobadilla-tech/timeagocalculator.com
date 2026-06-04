class CountdownsController < ApplicationController
  include SeoMetaTaggable

  before_action :set_countdown, only: [ :show, :edit, :update, :destroy, :unlock, :authenticate, :toggle_lock, :toggle_publish ]
  before_action :require_ownership!, only: [ :edit, :update, :destroy, :toggle_lock, :toggle_publish ]
  before_action :require_unlocked!, only: [ :edit, :update ]

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
    @countdown.user = Current.user if Current.user
    if @countdown.save
      redirect_to shared_countdown_path(@countdown.token)
    else
      set_meta_tags(title: "Create a Countdown Timer")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if !@countdown.is_public? && !@countdown.owned_by?(Current.user)
      redirect_to root_path, alert: "This countdown is private." and return
    end
    if @countdown.protected? && !password_authenticated? && !@countdown.owned_by?(Current.user)
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

  def edit
    set_meta_tags(title: "Edit #{@countdown.title}")
  end

  def update
    if @countdown.update(update_params)
      redirect_to shared_countdown_path(@countdown.token), notice: "Countdown updated."
    else
      set_meta_tags(title: "Edit #{@countdown.title}")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @countdown.destroy
    redirect_to new_countdown_path, notice: "Countdown deleted."
  end

  def toggle_lock
    @countdown.update!(locked: !@countdown.locked?)
    redirect_to shared_countdown_path(@countdown.token),
                notice: @countdown.locked? ? "Countdown locked — no further edits allowed." : "Countdown unlocked."
  end

  def toggle_publish
    @countdown.update!(published: !@countdown.published?)
    redirect_to dashboard_path,
                notice: @countdown.published? ? "Countdown published to your profile." : "Countdown removed from your profile."
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

  def require_ownership!
    unless @countdown.owned_by?(Current.user)
      redirect_to shared_countdown_path(@countdown.token), alert: "Not authorized." and return
    end
  end

  def require_unlocked!
    if @countdown.locked?
      redirect_to shared_countdown_path(@countdown.token), alert: "This countdown is locked and cannot be edited." and return
    end
  end

  def password_authenticated?
    session["countdown_auth_#{@countdown.token}"] == true
  end

  def countdown_params
    params.expect(countdown: [ :title, :target_date, :description, :is_public,
                                :published, :password, :password_confirmation ])
  end

  def update_params
    params.expect(countdown: [ :title, :target_date, :description, :is_public,
                                :published, :password, :password_confirmation ])
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
