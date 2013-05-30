require 'spec_helper'

describe Converter do
  let(:response) { mock :content => 'content', :body_encoding => 'utf-8' }

  subject { Converter.new(response) }

  it { should respond_to :content }
  it { should respond_to :encoding }
end