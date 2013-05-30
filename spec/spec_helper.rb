ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'fakeweb'
require File.expand_path '../../app.rb', __FILE__

FakeWeb.allow_net_connect = false

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.mock_with :rspec
end