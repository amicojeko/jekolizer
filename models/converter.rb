class Converter
  attr_reader :content, :encoding

  def self.convert(response)
    new(response).to_utf8
  end

  def initialize(response)
    @content  = response.content
    @encoding = response.encoding
  end

  def to_utf8
    converter.convert(content) rescue content
  end

  private

  def converter
    Encoding::Converter.new(encoding, 'UTF-8')
  end
end