require 'spec_helper'

describe Cacher do
  let(:token) { mock }
  let(:html)  { mock }

  describe '#store' do
    it 'delegates to REDIS.set' do
      REDIS.should_receive :set
      Cacher.store token, html
    end
  end

  describe '#retrieve' do
    it 'delegates to REDIS.get' do
      REDIS.should_receive :get
      Cacher.retrieve token
    end

    it 'returns nil when an error occurs' do
      REDIS.stub(:find) { raise ArgumentError }
      Cacher.retrieve(token).should be_nil
    end
  end
end
