require 'spec_helper'

describe Renderer do
  let :page do
    stub(
      :host => 'example.com',
      :replacements => stub,
      :original_content => '<html><head></head><body></body></html>'
    )
  end

  subject { Renderer.new page }

  it 'reads analytics html file' do
    subject.analytics_code.should =~ /getElementsByTagName/
  end

  it 'has expected base tag' do
    tag = '<base href="http://example.com/" target="_blank">'
    subject.base_tag.should == tag
  end

  describe '#prepared_body' do
    it 'add base tag in head' do
      subject.prepared_body.should include subject.base_tag
    end

    it 'add google analytics js code' do
      subject.prepared_body.should include subject.analytics_code
    end
  end
end