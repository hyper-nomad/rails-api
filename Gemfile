source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'mysql2'

# mysql5.6からdatetimeの小数点以下扱いが変わる問題のパッチ
gem 'activerecord-mysql-awesome'

gem 'devise', '~> 3.5'
gem 'doorkeeper'
gem 'omniauth'

# Facebook
gem 'omniauth-facebook'
gem 'koala'

#background
gem 'sidekiq'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'haml'
gem 'slim'

gem 'grape'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-rails'

gem 'rack-contrib'

#github: https://github.com/geokit/geokit-rails/issues/67 ...
gem 'geokit-rails', github: 'geokit/geokit-rails'

gem 'cancancan', '~> 1.10'
gem 'grape-cancan'

gem 'inherited_resources'
gem 'draper', '>= 1.0.0'

# Image Uploader
gem 'carrierwave'
gem 'fog'
gem 'jquery-fileupload-rails'
gem "select2-rails"

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem "seedbank"

gem 'acts-as-taggable-on', '~> 3.4'
gem 'enum_help'

gem "awesome_print"

gem 'unicorn', '4.8.3'
gem "asset_sync"
gem 'memoist'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem 'letter_opener_web'
end

group :development, :test do
  gem 'spring'
  gem 'spring-commands-rspec'

  gem "rspec"
  gem "rspec-rails"
  gem 'guard-rspec', require: false
  gem 'terminal-notifier-guard' #for mac

  gem "factory_girl"
  gem "factory_girl_rails"

  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'

  gem 'quiet_assets'

  gem 'hirb'
  gem 'hirb-unicode'

  gem 'json_expressions'
  gem 'capistrano', '~> 3.3.5'
  gem 'capistrano-ext', '~> 1.2.1'
  gem 'capistrano-bundler', '~> 1.1.4'
  gem 'capistrano-rails', '~> 1.1.2'
  gem 'capistrano-rbenv', '~> 2.0.3'
  gem 'capistrano-assets-sync'
  gem 'ruby-termios'
  gem 'highline'

  gem 'activerecord-cause'
end

group :test do
  gem 'database_cleaner'
end
