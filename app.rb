# Require all the gems in the Gemfile
require 'rubygems'
require 'sinatra'
require 'bundler'
require 'json'
require 'active_support/core_ext'

Bundler.require

require "#{settings.root}/models/converter"
require "#{settings.root}/models/renderer"
require "#{settings.root}/models/cacher"
require "#{settings.root}/models/page"
require "#{settings.root}/lib/assets_proxy"

CACHE_PAGES = ENV['CACHE_PAGES']
redis_uri = URI.parse(ENV["REDIS_URL"] || ENV["REDISTOGO_URL"] || 'redis://localhost:6379')
REDIS = Redis.new host: redis_uri.host, port: redis_uri.port, password: redis_uri.password

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

post '/generate' do
  @page = Page.new params[:url], params[:replacements].values.map(&:values)
  @page.save
  @url = "#{base_url}/#{@page.token}"
  if params[:json]
    content_type :json
    {url: @url}.to_json
  else
    erb :index
  end
end

get '/favicon.ico' do
end

get '/:shortcode' do
  Page.load(params[:shortcode]).render
end
