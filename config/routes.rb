Rails.application.routes.draw do
  root to: proc { |env| [200, {}, ["soon"]] } if %w(production staging).include? Rails.env.to_s

  devise_for :users,
             controllers: {
               omniauth_callbacks: 'omniauth_callbacks',
               confirmations: 'devise_users/confirmations',
             }
  devise_for :admin_users
  devise_for :merchant_users

  # API
  mount RedishAPI::Root => '/api/'
  mount GrapeSwaggerRails::Engine => '/docs'

  # TODO: 検討
  # scope :app, module: :app_web_view do
    # match 'registrations/thanks', via: :get
  # end
  # devise_scope :user do
    # get 'app/users/confirmation', controller: 'devise_users/confirmations', action: :show
  # end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # varnish, nginx check
  match "alive", :to => proc { |env| [200, {}, ["Number 5 is alive!"]] }, :via => :get
end
