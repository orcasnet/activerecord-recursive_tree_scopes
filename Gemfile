source 'http://rubygems.org'

gem 'activerecord', '>= 3.1'

group :development do
  gem 'rspec',   '~> 2.8.0'
  gem 'rdoc',    '~> 3.12'
  gem 'bundler', '~> 1.0'
  gem 'jeweler', '~> 1.8.7'
end

group :test do
  platforms :jruby do
    gem 'activerecord-jdbcpostgresql-adapter'
  end
  platforms :ruby do
    gem 'pg'
  end
end
