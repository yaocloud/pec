# encoding: utf-8
require 'pec'
require 'pec/configure'
require 'rspec'

Dir["./support/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
end
