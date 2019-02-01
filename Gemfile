source 'http://rubygems.org'

ruby '~> 2.2.0'
gem 'rails', '4.1.4'

# Paperclip adds file upload support to ActiveRecord models
gem 'paperclip', '~> 4.2.0'

# Rails 4 removed attr_accessible and attr_protected from your models.
# Per https://github.com/collectiveidea/delayed_job/blob/master/README.md
# If you are using the protected_attributes gem, it must appear before delayed_job in your gemfile.

gem 'protected_attributes', '~> 1.0.8'

# delayed_job allows background asynchronous jobs
# it used to import uploaded files
gem 'delayed_job', '~> 4.0.0'

# delayed_job_active_record 4.0.0 has issues with postgres 8.4
# This version has a workaround
gem 'delayed_job_active_record', '~> 4.0.0'
gem "daemons"

# devise for user accounts
gem 'devise', '~> 3.3.0'

# OmniAuth for open id in devise
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-openid', '~> 1.0.1'
gem 'omniauth-google-oauth2'

# Wicked for step-by-step wizard in data upload
gem 'wicked'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg', '~> 0.17.1'

# Formerly in the assets group
gem 'sass-rails',   '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-tablesorter', '~> 1.12.6'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

# CSS and JS from twitter bootstrap.
# Could easily be made static
gem 'less-rails-bootstrap', '~> 2.3.3'
gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '~> 2.5.1'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

group :test do
  gem 'rake'
  gem 'capybara', '~> 2.2.1'
  gem 'poltergeist', '~> 1.5.0'
  gem 'coveralls', require: false
  gem 'webmock', '~> 1.17.4'
end

gem 'thin'
gem 'rails_12factor', group: :production
gem 'aws-sdk', '~> 1.51.0'
