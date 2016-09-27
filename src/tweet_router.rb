require 'sinatra'
require 'sinatra/reloader'
require 'json'
require_relative 'utils/http_helper'
require_relative 'entity/tweet'

# Sinatra Tweet controller
class TweetRouter < Sinatra::Base
  include HttpHelper

  get '/tweets' do
    tweets = Tweet.new.db
    tweets.all.to_json
  end

  get '/tweets/:id' do
    result = Tweet.new.find(id: params[:id].to_i)
    create_response(result)
  end

  post '/tweets', provides: :json do
    result = Tweet.new.save(json_request)
    create_response(result)
  end
end
