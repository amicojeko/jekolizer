# Require all the gems in the Gemfile
require 'rubygems'
require 'sinatra'
require 'bundler'
Bundler.require

require File.join File.dirname(__FILE__), 'jekolized_page'


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
end


get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    @jekolized_page = JekolizedPage.new params[:url], [params[:s1], params[:r1]]
    @jekolized_page.save
  end
  erb :index
end

get '/:shortcode' do
  jekolized_page = JekolizedPage.load params[:shortcode]
  jekolized_page.render
end