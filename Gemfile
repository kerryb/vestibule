source "http://rubygems.org"
ruby "1.9.3"

gem "rails", "3.2.13"
gem "pg", "0.14.1"
gem "simple_form", "2.0.4"
gem "omniauth"
gem 'iuser_auth', git: 'https://gitlab.nat.bt.com/iuser_auth/iuser_auth.git'
gem "httparty", "0.12.0"
gem "paper_trail", "1.6.4"
gem "redcarpet", "2.2.2"
gem "bootstrap-sass"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  gem "mocha", "0.13.1", :require => false
  gem "webmock", "1.13.0"
end

group :test do
  gem "factory_girl_rails", "4.1.0"
  gem "shoulda", "3.3.2"
  gem "capybara", "1.1.4"
  gem "database_cleaner", "0.9.1"
  gem "mocha", "0.13.1", :require => false
  gem "faker", "1.1.2"
  gem "timecop", "0.5.7"
  gem "webmock", "1.13.0"

  # Things that aren't *required*, but you might need as you go.
  gem "pry"
  gem "launchy"
  gem "escape_utils", "0.1.9"
end
