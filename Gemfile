source 'https://rubygems.org'

# Specify your gem's dependencies in .gemspec
gemspec

if `cd ..; git remote -v`.include?('countdown')
  gem 'credentials_manager', path: '../credentials_manager'
end
