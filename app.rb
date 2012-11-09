require 'sinatra'  
require 'redis'  
require 'net/http'

configure do
  ENV["REDISTOGO_URL"] = 'redis://redistogo:52688109ddc301de4832640b629b4728@slimehead.redistogo.com:9449' 
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end



#REDIS = Redis.new  




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
    REDIS.setnx "links:#{@shortcode}", params[:url]  
    REDIS.setnx "links:#{@shortcode}s1", params[:s1]
    REDIS.setnx "links:#{@shortcode}r1", params[:r1]
    @host = "http://" << request.host
    @host << ":" << request.port.to_s unless request.port == 80
  end  
  erb :index  
end  
get '/:shortcode' do  
  @url = REDIS.get "links:#{params[:shortcode]}"  
  search = REDIS.get "links:#{params[:shortcode]}s1"
  replace = REDIS.get "links:#{params[:shortcode]}r1"  
  #redirect @url || '/'  
  url = URI.parse(@url)
    req = Net::HTTP::Get.new(url.path)

    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

  body = res.body.gsub("<head>", "<head><base href=\"http://#{url.host}/\" target=\"_blank\">")
  body.gsub!(search, replace)

end