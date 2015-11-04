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

configure do
  if production?
    CACHE_PAGES = true
    uri = URI.parse ENV["REDISTOGO_URL"]
    REDIS = Redis.new :host => uri.host, :port => uri.port, :password => uri.password
    id, secret = ENV['AWS_S3_ID'], ENV['AWS_S3_SECRET']
    AWS::S3::Base.establish_connection! :access_key_id => id, :secret_access_key => secret
  else
    CACHE_PAGES = false
    REDIS = Redis.new :host => 'localhost', :port => 6379
  end
end


helpers do
  include Rack::Utils
  alias :h :escape_html

  def production?
    ENV['REDISTOGO_URL']
  end

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
