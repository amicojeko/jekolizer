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
    return nil if !attributes or attributes.empty?
    new attributes['url'], JSON.parse(attributes['replacements']), token
  end

  def save
    set_token
    attributes.each do |name, value|
      REDIS.hset token, name, value
    end
  end

  def set_token
    self.token ||= REDIS.incr('token_count').to_s 36
  end

  def attributes
    {:url => url, :host => host, :replacements => replacements.to_s}
  end

  def host
    URI(url).host
  end

  def url
    @url =~ Regexp.new('http://') ? @url : "http://#{@url}"
  end

  def original_content
    @original_content ||= Converter.convert(response)
  end

  def google_analytics_code
    @analytics ||= File.read 'views/analytics.html'
  end

  def render
    retrieve_html_from_cache
    html_present? ? html.value : build_html
  end

  private

  def response
    @response ||= HTTPClient.get url
  end

  def each_text_node html_doc, &block
    html_doc.css('body *:not(script), head > title').each do |tag|
      tag.children.each do |node|
        yield(node) if node.text?
      end
    end
  end

  def replace_meta_description
    doc.css('head > meta[name="description"]').each do |tag|
      tag['content'] = replace_occurrences_in tag['content'].to_s
    end
  end

  def replace_occurrences_in string
    replacements.each do |pair|
      search, replace = *pair
      string.gsub!(/(#{search})/i, replace) unless search.strip.empty?
    end
    string
  end

  def should_cache?
    CACHE_PAGES
  end

  def retrieve_html_from_cache
    self.html = find_from_cache if should_cache?
  end

  def html_present?
    html.to_s.present?
  end

  def build_html
    replace_keywords
    set_html
  end

  def cache html
    Cacher.store token, html
  end

  def find_from_cache
    Cacher.retrieve token
  end

  def prepare_body
    body = original_content.tap do |body|
      body.gsub! '<head>',  %(<head><base href="http://#{host}/" target="_blank">)
      body.gsub! '</body>', "#{google_analytics_code}\n</body>"
    end
  end

  def replace_keywords
    self.doc  = Nokogiri::HTML prepare_body
    each_text_node(doc) { |node| node.content = replace_occurrences_in(node.content) }
    replace_meta_description
  end

  def set_html
    html = doc.inner_html
    cache html if should_cache?
    self.html = html
  end
end