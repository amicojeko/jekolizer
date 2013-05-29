require File.expand_path '../../spec_helper', __FILE__

describe Page do
  def replacements; mock; end
  def rel_url; 'www.mikamai.com/url'; end
  def abs_url; 'http://mikamai.com/another'; end

  subject { Page.new abs_url ,replacements }

  it { subject.attributes.should be_a Hash }

  it { should respond_to :token }
  it { should respond_to :html }
  it { should respond_to :doc }

  describe '#url' do
    it 'includes protocol' do
      subject.url[0..6].should == 'http://'
    end

    it 'includes protocol when missing' do
      subject.instance_variable_set '@url', rel_url
      subject.url[0..6].should == 'http://'
    end
  end

  it '#host extracts the host from url' do
    subject.host.should == 'mikamai.com'
  end

  describe '#token' do
    it { subject.token.should be_nil }

    it '#set_token creates a token' do
      subject.set_token
      subject.token.should be_present
    end
  end

  it '#original_content caches value' do
    subject.stub :content => mock
    Converter.should_receive(:convert).and_return mock
    2.times { subject.original_content }
  end

  it 'reads analytics html file' do
    subject.google_analytics_code.should =~ /getElementsByTagName/
  end
end