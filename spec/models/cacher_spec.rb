require 'spec_helper'

describe Cacher do
  let(:token) { mock }
  let(:html)  { mock }

  describe '#store' do
    it 'delegates to AWS::S3::S3Object.store' do
      AWS::S3::S3Object.should_receive :store
      Cacher.store token, html
    end
  end

  describe '#retrieve' do
    it 'delegates to AWS::S3::S3Object.find' do
      AWS::S3::S3Object.should_receive :find
      Cacher.retrieve token
    end

    it 'returns nil when an error occurs' do
      AWS::S3::S3Object.stub(:find) { raise ArgumentError }
      Cacher.retrieve(token).should be_nil
    end
  end
end