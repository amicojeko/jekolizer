class Renderer
  attr_reader :page
  attr_accessor :doc, :host, :replacements, :content

  def initialize(page)
    @page = page
    @host = page.host
    @content = page.original_content
    @replacements = page.replacements
  end

  def html
    self.doc = Nokogiri::HTML prepared_body
    replace_in_body
    replace_in_meta_description
    doc.inner_html
  end

 def prepared_body
    content.tap do |body|
      body.gsub! '<head>',  "<head>#{base_tag}"
      body.gsub! '</body>', "#{analytics_code}\n</body>"
    end
  end

  def base_tag
    %(<base href="http://#{host}/" target="_blank">)
  end

  def replace_in_body
    doc.css('body *:not(script), head > title').each do |tag|
      tag.children.each do |node|
        if node.text?
          node.content = replace_in node.content
        end
      end
    end
  end

  def replace_in_meta_description
    doc.css('head > meta[name="description"]').each do |tag|
      tag['content'] = replace_in tag['content']
    end
  end

  def replace_in string
    replacements.each do |pair|
      search, replace = *pair
      string.gsub!(/(#{search})/i, replace)
    end
    string
  end

  def analytics_code
    @analytics_code ||= File.read 'views/analytics.html'
  end
end