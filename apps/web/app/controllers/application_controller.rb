class ApplicationController < ActionController::Base
  include Authentication
  include MetaTags::ControllerHelper

  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  # Override: all pages public by default — just load session, don't redirect.
  # Controllers needing enforced auth define their own before_action.
  def require_authentication
    resume_session
  end
end
