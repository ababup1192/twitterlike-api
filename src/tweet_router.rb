require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require_relative 'utils/http_helper'
require_relative 'entity/tweet'

# Sinatra Tweet controller
class TweetRouter < Sinatra::Base
  include HttpHelper

  get '/tweets' do
    tweets = Tweet.new.db
    json tweets.all
  end

  get '/tweets/:id' do
    result = Tweet.new.find(params[:id].to_i)
    create_response(result)
  end

  get '/tweets/user/:user_id' do
    result = Tweet.new.find_by_user_id(params[:user_id].to_i)
    create_response(result)
  end

  get '/tweets/timeline/:user_id' do
    result = Tweet.new.timeline(params[:user_id].to_i)
    create_response(result)
  end

  post '/tweets', provides: :json do
    result = Tweet.new.save(json_request)
    create_response(result)
  end
end
