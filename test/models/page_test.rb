require File.expand_path '../../test_helper.rb', __FILE__

class PageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def replacements; mock; end
  def rel_url; 'www.mikamai.com/url'; end
  def abs_url; 'http://mikamai.com/another'; end

  def setup
    @page = Page.new abs_url ,replacements
  end

  def test_attributes_is_a_hash
    assert Hash === @page.attributes
  end

  def test_url_includes_protocol
    assert_equal 'http://', @page.url[0..6]
  end

  def test_url_includes_protocol_if_missing
    @page.instance_variable_set '@url', rel_url
    assert_equal 'http://', @page.url[0..6]
  end

  def test_host_extract_host_from_url
    assert_equal 'mikamai.com', @page.host
  end

  def test_has_no_token
    refute @page.token
  end

  def test_set_token_creates_a_token
    @page.set_token
    assert @page.token
  end
end