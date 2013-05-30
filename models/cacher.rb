module Cacher
  extend self

  def name
    'jekolizer'
  end

  def store(token, html)
    AWS::S3::S3Object.store token, html, name
  end

  def retrieve(token)
    AWS::S3::S3Object.find(token, name) rescue nil
  end
end