Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get  "/sign-up", to: "registrations#new",    as: :new_registration
  post "/sign-up", to: "registrations#create", as: :registrations

  get "up" => "rails/health#show", as: :rails_health_check

  get "/time-ago-calculator",        to: "calculators/time_ago#show",        as: :time_ago_calculator
  get "/time-until-calculator",      to: "calculators/time_until#show",      as: :time_until_calculator
  get "/date-difference-calculator", to: "calculators/date_difference#show", as: :date_difference_calculator
  get "/age-calculator",             to: "calculators/age#show",             as: :age_calculator

  get  "/countdowns/new",   to: "countdowns#new",          as: :new_countdown
  post "/countdowns",       to: "countdowns#create",        as: :countdowns
  get  "/c/:token/edit",    to: "countdowns#edit",          as: :edit_countdown
  get  "/c/:token",         to: "countdowns#show",          as: :shared_countdown
  patch "/c/:token",        to: "countdowns#update"
  delete "/c/:token",       to: "countdowns#destroy"
  get  "/c/:token/unlock",  to: "countdowns#unlock",        as: :unlock_countdown
  post "/c/:token/unlock",  to: "countdowns#authenticate",  as: :authenticate_countdown
  patch  "/c/:token/lock",      to: "countdowns#toggle_lock",         as: :toggle_lock_countdown
  post   "/c/:token/favorite",  to: "countdown_favorites#create",     as: :favorite_countdown
  delete "/c/:token/favorite",  to: "countdown_favorites#destroy",    as: :unfavorite_countdown

  get "/dashboard", to: "dashboard#index", as: :dashboard

  get "/countdown/new", to: redirect("/countdowns/new")

  get "/how-long-ago/:slug", to: "events#show",   as: :how_long_ago,  constraints: { slug: /[a-z0-9\-]+/ }
  get "/countdown/:slug",    to: "holidays#show", as: :countdown,     constraints: { slug: /[a-z0-9\-]+/ }
  get "/age/:slug",          to: "people#show",   as: :age_page,      constraints: { slug: /[a-z0-9\-]+/ }

  root to: "calculators/time_ago#show"
end
