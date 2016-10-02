require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'sinatra/json'
require_relative 'utils/http_helper'
require_relative 'entity/follow'

# Sinatra Follow controller
class FollowRouter < Sinatra::Base
  include HttpHelper

  configure do
    register Sinatra::Reloader
    register Sinatra::CrossOrigin
  end

  get '/follows' do
    cross_origin
    follows = Follow.new.db
    json follows.all
  end

  get '/follows/:id' do
    result = Follow.new.find(params[:id].to_i)
    create_response(result)
  end

  post '/follows', provides: :json do
    result = Follow.new.save(json_request)
    create_response(result)
  end
end
