require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require_relative 'user_router'
require_relative 'tweet_router'
require_relative 'follow_router'

# Sinatra Main controller
class MainApp < Sinatra::Base
  include HttpHelper

  configure do
    register Sinatra::Reloader
    register Sinatra::CrossOrigin
  end

  use UserRouter
  use TweetRouter
  use FollowRouter
end
