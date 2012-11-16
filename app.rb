# Require all the gems in the Gemfile
require 'rubygems'
require 'sinatra'
require 'bundler'
require 'json'
Bundler.require

require "#{settings.root}/models/page"
require "#{settings.root}/lib/assets_proxy"

configure do
  if ENV["REDISTOGO_URL"]
    uri = URI.parse ENV["REDISTOGO_URL"]
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    REDIS = Redis.new(:host => 'localhost', :port => 6379)
  end
end


helpers do
  include Rack::Utils
  alias :h :escape_html

  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end


get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    @page = JekolizedPage.new params[:url], params[:replacements].values.map(&:values)
    @page.save
  end
  erb :index
end

get '/:shortcode' do
  page = JekolizedPage.load params[:shortcode]
  page.render
end