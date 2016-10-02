require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require_relative 'utils/http_helper'
require_relative 'entity/follow'

# Sinatra Follow controller
class FollowRouter < Sinatra::Base
  include HttpHelper

  get '/follows' do
    follows = Follow.new.db
    json follows.all
  end

  get '/follows/:id' do
    result = Follow.new.find(params[:id].to_i)
    create_response(result)
  end

  get 'follows/:user_id/unfollow' do
  end

  post '/follows', provides: :json do
    result = Follow.new.save(json_request)
    create_response(result)
  end
end
