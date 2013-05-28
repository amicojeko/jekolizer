# test_helper.rb
ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/pride'
require 'rack/test'

require File.expand_path '../../app.rb', __FILE__

def mock(opts={})
  mock = MiniTest::Mock.new
  opts.each do |method_name, result|
    mock.expect method_name, result
  end
end