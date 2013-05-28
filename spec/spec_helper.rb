ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'rr'
require File.expand_path '../../app.rb', __FILE__

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.mock_with :rr
end