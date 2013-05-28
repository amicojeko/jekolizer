require File.expand_path '../../test_helper.rb', __FILE__
require 'pry'

class PageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def url; 'some/url'; end
  def replacements; mock; end
  def token; 'some_unique_id'; end

  def setup
    @page = Page.new url ,replacements, token
  end

  def test_attributes_is_a_hash
    assert Hash === @page.attributes
  end
end