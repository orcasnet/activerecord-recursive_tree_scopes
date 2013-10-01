source 'http://rubygems.org'

gem 'activerecord', '>= 3'

group :development do
  gem 'rspec'
  gem 'rdoc'
  gem 'bundler'
  gem 'jeweler'
end

group :test do
  platforms :jruby do
    gem 'activerecord-jdbcpostgresql-adapter'
  end
  platforms :ruby do
    gem 'pg'
  end
end
