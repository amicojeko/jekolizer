class JekolizedPage
  attr_reader :replacements, :token

  def initialize url, replacements, token=nil
    @url = url
    @replacements = replacements
    @token = token
  end

  def self.load token
    attributes = REDIS.hgetall token
    return nil if !attributes or attributes.empty?
    JekolizedPage.new attributes['url'], [attributes['search'], attributes['replace']], token
  end

  def save
    @token ||= generate_unique_token
    attributes = {:url => url, :host => host, :search => replacements[0], :replace => replacements[1]}
    attributes.each { |key, value| REDIS.hset(@token, key, value) }
  end

  def generate_unique_token
    REDIS.incr('token_count').to_s 36
  end

  def host
    URI(url).host
  end

  def url
    @url =~ /http:\/\//i ? @url : "http://#{@url}"
  end

  def original_content
    @original_content ||= HTTPClient.get_content url
  end

  def render
    body = original_content
    body.gsub! "<head>", "<head><base href=\"http://#{host}/\" target=\"_blank\">"
    body.gsub! replacements[0], replacements[1]
    body
  end
end