class ProfilesController < ApplicationController
  include SeoMetaTaggable

  def show
    @profile_user = User.find_by!(username: params[:username])
    @countdowns = @profile_user.countdowns
                               .where(is_public: true, published: true)
                               .order(created_at: :desc)
    set_meta_tags(
      title: "@#{@profile_user.username}'s Countdowns",
      description: "Countdown timers shared by #{@profile_user.username}.",
      canonical: user_profile_url(@profile_user.username)
    )
  end
end
