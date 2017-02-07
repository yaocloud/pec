# encoding: utf-8
require 'pec'
require 'rspec'
require 'simplecov'
SimpleCov.start

Dir["./support/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
end

