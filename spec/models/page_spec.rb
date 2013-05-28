require File.expand_path '../../spec_helper', __FILE__

describe Page do
  def replacements; mock; end
  def rel_url; 'www.mikamai.com/url'; end
  def abs_url; 'http://mikamai.com/another'; end

  subject { Page.new abs_url ,replacements }

  it { subject.attributes.should be_a Hash }

  it '#url includes protocol' do
    subject.url[0..6].should == 'http://'
  end

  it '#url includes protocol when missing' do
    subject.instance_variable_set '@url', rel_url
    subject.url[0..6].should == 'http://'
  end

  it '#host extracts the host from url' do
    subject.host.should == 'mikamai.com'
  end

  it { subject.token.should be_nil }

  it '#set_token creates a token' do
    subject.set_token
    subject.token.should be_present
  end
end