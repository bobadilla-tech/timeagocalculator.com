class ApplicationController < ActionController::Base
  include Authentication
  include MetaTags::ControllerHelper

  allow_unauthenticated_access  # public site — opt-in auth per controller/action

  allow_browser versions: :modern
  stale_when_importmap_changes
end
