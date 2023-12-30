get '/stylesheets/*.css' do
  content_type 'text/css', :charset => 'utf-8'
  filename = params[:splat].first
  sass filename.to_sym, :views => "#{settings.root}/public/stylesheets"
end

get '/javascripts/*.js' do
  content_type 'text/javascript', :charset => 'utf-8'
  filename = params[:splat].first
  coffee_code = File.read("#{settings.root}/public/javascripts/#{filename}.coffee")
  CoffeeScript.compile coffee_code, :views => "#{settings.root}/public/javascripts"
end
