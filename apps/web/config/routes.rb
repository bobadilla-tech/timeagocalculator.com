Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get  "/sign-up", to: "registrations#new",    as: :new_registration
  post "/sign-up", to: "registrations#create", as: :registrations

  get "up" => "rails/health#show", as: :rails_health_check

  get "/time-ago-calculator",        to: "calculators/time_ago#show",         as: :time_ago_calculator
  get "/hours-ago",                  to: "calculators/hours_ago#show",      as: :hours_ago_calculator
  get "/time-until-calculator",      to: "calculators/time_until#show",       as: :time_until_calculator
  get "/date-difference-calculator", to: "calculators/date_difference#show",  as: :date_difference_calculator
  get "/age-calculator",             to: "calculators/age#show",              as: :age_calculator
  get  "/business-days-calculator",      to: "calculators/business_days#show",  as: :business_days_calculator
  get  "/countdown-widget-builder",    to: "widgets#builder",                 as: :countdown_widget_builder
  get  "/widget/countdown",            to: "widgets#countdown",               as: :countdown_widget
  get  "/date-calculator",             to: "pages#date_calculator",             as: :date_calculator
  get  "/day-of-the-week",             to: "calculators/day_of_the_week#show",  as: :day_of_the_week
  get  "/recurring-date-finder",       to: "pages#recurring_date_finder",       as: :recurring_date_finder
  get  "/week-number",                 to: "pages#week_number",                 as: :week_number
  get  "/anniversary-calculator",      to: "pages#anniversary_calculator",      as: :anniversary_calculator
  get  "/privacy-policy",              to: "pages#privacy_policy",              as: :privacy_policy
  get  "/terms-of-service",            to: "pages#terms_of_service",            as: :terms_of_service
  get  "/contact",                     to: "pages#contact",                     as: :contact
  get  "/faqs",                        to: "pages#faqs",                        as: :faqs
  get  "/feedback",                    to: "pages#feedback",                    as: :feedback
  post "/feedback",                    to: "pages#submit_feedback"
  get  "/report-a-bug",                to: "pages#report_a_bug",                as: :report_a_bug
  post "/report-a-bug",                to: "pages#submit_report_a_bug"
  post "/business-days-calculations", to: "business_days_calculations#create",  as: :business_days_calculations
  get  "/bd/:token",                  to: "business_days_calculations#show",    as: :business_days_calculation
  delete "/bd/:token",                to: "business_days_calculations#destroy", as: :destroy_business_days_calculation

  get "/business-days/this-month",              to: "business_days_month#this_month",         as: :business_days_this_month
  get "/business-days/:country/this-month",     to: "business_days_month#this_month_country", as: :business_days_this_month_country, constraints: { country: /[a-z\-]+/ }
  get "/business-days/:year/:month",            to: "business_days_month#show",               as: :business_days_month,         constraints: { year: /\d{4}/, month: /[a-z]+/ }
  get "/business-days/:country/:year/:month",   to: "business_days_month#show",               as: :business_days_month_country, constraints: { country: /[a-z\-]+/, year: /\d{4}/, month: /[a-z]+/ }

  get  "/countdowns/new",   to: "countdowns#new",          as: :new_countdown
  post "/countdowns",       to: "countdowns#create",        as: :countdowns
  get  "/c/:token/edit",    to: "countdowns#edit",          as: :edit_countdown
  get  "/c/:token",         to: "countdowns#show",          as: :shared_countdown
  patch "/c/:token",        to: "countdowns#update"
  delete "/c/:token",       to: "countdowns#destroy"
  get  "/c/:token/unlock",  to: "countdowns#unlock",        as: :unlock_countdown
  post "/c/:token/unlock",  to: "countdowns#authenticate",  as: :authenticate_countdown
  patch  "/c/:token/lock",    to: "countdowns#toggle_lock",    as: :toggle_lock_countdown
  patch  "/c/:token/publish", to: "countdowns#toggle_publish", as: :toggle_publish_countdown
  post   "/c/:token/favorite",  to: "countdown_favorites#create",  as: :favorite_countdown
  delete "/c/:token/favorite",  to: "countdown_favorites#destroy", as: :unfavorite_countdown

  get "/dashboard", to: "dashboard#index", as: :dashboard

  get "/u/:username", to: "profiles#show", as: :user_profile, constraints: { username: /[a-z0-9_]+/ }

  get "/countdown/new", to: redirect("/countdowns/new")

  get "/events",                              to: "events#index",           as: :events
  get "/events/historical",                   to: "events#historical",      as: :historical_events
  get "/events/category/:category",           to: "events#by_category",     as: :events_by_category,      constraints: { category: /[a-z\-]+/ }
  get "/events/country/:country",             to: "events#by_country",      as: :events_by_country,       constraints: { country: /[a-z\-]+/ }
  get "/events/country/:country/:year",       to: "events#by_country",      as: :events_by_country_year,  constraints: { country: /[a-z\-]+/, year: /\d{4}/ }
  get "/events/:slug",                        to: "events#show_event",      as: :event,                   constraints: { slug: /[a-z0-9\-]+/ }
  get "/how-long-ago/:slug",                  to: "events#show",            as: :how_long_ago,            constraints: { slug: /[a-z0-9\-]+/ }
  get "/countdown/:slug",    to: "holidays#show",          as: :countdown,       constraints: { slug: /[a-z0-9\-]+/ }
  get "/age/:slug",          to: "people#show",   as: :age_page,      constraints: { slug: /[a-z0-9\-]+/ }

  get "/date/:year/:month/:day", to: "date_pages#show", as: :date_page,
      constraints: { year: /\d{4}/, month: /[a-z]+/, day: /\d{1,2}/ }

  root to: "home#index"
end
