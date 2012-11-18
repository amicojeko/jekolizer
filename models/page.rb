class Page
  attr_reader :replacements, :token

  def initialize url, replacements, token=nil
    @url = url
    @replacements = replacements
    @token = token
  end

  def self.load token
    attributes = REDIS.hgetall token
    return nil if !attributes or attributes.empty?
    new attributes['url'], JSON.parse(attributes['replacements']), token
  end

  def save
    @token ||= generate_unique_token
    attributes = {:url => url, :host => host, :replacements => replacements.to_s}
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
    doc = Nokogiri::HTML body
    each_text_node(doc) { |node| node.content = replace_occurrences_in(node.content) }
    doc.inner_html
  end

  private

  def each_text_node html_doc, &block
    html_doc.css('body *:not(script)').each do |tag|
      tag.children.each do |node|
        yield(node) if node.text?
      end
    end
  end

  def replace_occurrences_in string
    replacements.each do |pair|
      search, replace = *pair
      string.gsub!(/(#{search})/i, replace) unless search.strip.empty?
    end
    string
  end
end