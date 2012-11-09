require 'sinatra'  
require 'redis'  
require 'net/http'

redis = Redis.new  
helpers do  
  include Rack::Utils  
  alias_method :h, :escape_html  
  def random_string(length)  
    rand(36**length).to_s(36)  
  end  
end  
get '/' do  
  erb :index  
end  
post '/' do    
  if params[:url] and not params[:url].empty?  
    @shortcode = random_string 5  
    redis.setnx "links:#{@shortcode}", params[:url]  
    redis.setnx "links:#{@shortcode}s1", params[:s1]
    redis.setnx "links:#{@shortcode}r1", params[:r1]
    @host = "http://" << request.host
    @host << ":" << request.port.to_s unless request.port == 80
  end  
  erb :index  
end  
get '/:shortcode' do  
  @url = redis.get "links:#{params[:shortcode]}"  
  search = redis.get "links:#{params[:shortcode]}s1"
  replace = redis.get "links:#{params[:shortcode]}r1"  
  #redirect @url || '/'  
  url = URI.parse(@url)
    req = Net::HTTP::Get.new(url.path)

    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

  body = res.body.gsub("<head>", "<head><base href=\"http://#{url.host}/\" target=\"_blank\">")
  body.gsub!(search, replace)

end