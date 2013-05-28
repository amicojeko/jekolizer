class Page
  attr_reader :replacements
  attr_accessor :token

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
    begin
      ec = Encoding::Converter.new(response.body_encoding, 'UTF-8')
      content = ec.convert(response.content)
    rescue
      content = response.content
    end
    @original_content ||= content
  end

  def response
    @response ||= HTTPClient.get url
  end

  def render
    html = find_from_cache if CACHE_PAGES
    if html and html.to_s.strip.size > 0
      html.value
    else
      body = original_content
      body.gsub! "<head>", "<head><base href=\"http://#{host}/\" target=\"_blank\">"
      body.gsub! "</body>", "#{google_analytics_code}\n</body>"
      doc = Nokogiri::HTML body
      each_text_node(doc) { |node| node.content = replace_occurrences_in(node.content) }
      replace_meta_description doc
      html = doc.inner_html
      cache(html) if CACHE_PAGES
      html
    end
  end

  def google_analytics_code
    "<script type=\"text/javascript\">\n var _gaq = _gaq || [];\n _gaq.push(['_setAccount', 'UA-5736692-22']);\n _gaq.push(['_trackPageview']);\n (function() {\n var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);\n })();\n </script>"
  end

  def cache html
    AWS::S3::S3Object.store @token, html, 'jekolizer'
  end

  def find_from_cache
    AWS::S3::S3Object.find(@token, 'jekolizer') rescue nil
  end

  private

  def each_text_node html_doc, &block
    html_doc.css('body *:not(script), head > title').each do |tag|
      tag.children.each do |node|
        yield(node) if node.text?
      end
    end
  end

  def replace_meta_description html_doc
    html_doc.css('head > meta[name="description"]').each do |tag|
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
end