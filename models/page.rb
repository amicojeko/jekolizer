class Page
  attr_reader :replacements
  attr_accessor :token, :html

  def initialize url, replacements, token=nil
    @url = url.downcase
    @replacements = replacements
    @token = token
  end

  def self.load token
    attributes = REDIS.hgetall token
    if attributes.present?
      new attributes['url'], JSON.parse(attributes['replacements']), token
    end
  end

  def save
    set_token
    attributes.each do |name, value|
      REDIS.hset token, name, value.to_s
    end
  end

  def set_token
    self.token ||= REDIS.incr('token_count').to_s 36
  end

  def attributes
    {:url => url, :host => host, :replacements => replacements}
  end

  def host
    URI(url).host
  end

  def url
    @url =~ Regexp.new('http://') ? @url : "http://#{@url}"
  end

  def original_content
    @original_content ||= Converter.convert(remote_content)
  end

  def render
    retrieve_html_from_cache
    html.present? ? html.value : build_html
  end

  private

  def build_html
    self.html = Renderer.new(self).html
    cache html if should_cache?
    html
  end

  # TODO handle redirects
  def remote_content
    @remote_content ||= HTTPClient.get url
  end

  def should_cache?
    CACHE_PAGES
  end

  def retrieve_html_from_cache
    self.html = find_from_cache if should_cache?
  end

  def cache html
    Cacher.store token, html
  end

  def find_from_cache
    Cacher.retrieve token
  end
end