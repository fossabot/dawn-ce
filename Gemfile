# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Server
gem 'eventmachine'

# Database
gem 'mysql2', '~> 0.5.2'
gem 'sequel','~> 4.0'

# Utils
gem 'dalli', '~>2.0.2'
gem 'RubyInline','~>3.12.4'
gem 'gmp'
gem 'rake'

# Auth
gem 'oauth','~>0.4.5'

group :build do
  gem 'RocketAMF','~>0.2.1'
  gem 'sqlite3','~>1.3.11'
end

group :development, :test do
  gem 'rubocop', '~> 0.90', require: false
  gem 'rubocop-performance', require: false

  gem 'bundler-audit', require: false
end

group :development do
  gem 'dotenv'

  gem 'overcommit', require: false
end

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'

  gem 'cucumber'

  gem 'simplecov'
end