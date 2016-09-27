require 'sinatra'
require 'sinatra/reloader'
require 'json'
require_relative 'user_router'
require_relative 'tweet_router'

# Sinatra Main controller
class MainApp < Sinatra::Base
  include HttpHelper

  configure :development do
    register Sinatra::Reloader
  end

  use UserRouter
  use TweetRouter
end
