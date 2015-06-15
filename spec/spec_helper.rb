# encoding: utf-8
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'pec'
require 'pec/configure'
require 'pec/director'
require 'rspec'

Dir["./support/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
end

