require 'sinatra'
require 'sinatra/reloader'
require_relative 'user_router'
require_relative 'tweet_router'
require_relative 'follow_router'

# Sinatra Main controller
class MainApp < Sinatra::Base
  include HttpHelper

  configure :development do
    register Sinatra::Reloader
  end

  use UserRouter
  use TweetRouter
  use FollowRouter
end
