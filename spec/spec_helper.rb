# encoding: utf-8
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'pec'
require 'rspec'

Dir["./support/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
end

