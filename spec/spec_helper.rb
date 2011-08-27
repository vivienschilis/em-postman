$:.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'em-postman'
require 'rspec'
require 'em-spec/rspec'

RSpec.configure do |config|
  config.include EventMachine::SpecHelper
end
