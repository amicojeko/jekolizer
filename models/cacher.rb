module Cacher
  extend self

  def name
    'jekolizer'
  end

  def store(token, html)
    REDIS.set("#{name}:#{token}", html)
  end

  def retrieve(token)
    REDIS.get("#{name}:#{token}") rescue nil
  end
end
