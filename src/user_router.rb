require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require_relative 'utils/http_helper'
require_relative 'entity/user'
require_relative 'entity/session'

# Sinatra User controller
class UserRouter < Sinatra::Base
  include HttpHelper

  configure do
    register Sinatra::Reloader
    register Sinatra::CrossOrigin
  end

  get '/users' do
    cross_origin
    users = User.new.db
    json users.all
  end

  get '/users/:id' do
    result = User.new.find(params[:id].to_i)
    create_response(result)
  end

  get '/users/:id/unfollow' do
    cross_origin
    json User.new.unfollowers(params[:id].to_i)
  end

  get '/sessions' do
    cross_origin
    sessions = Session.new.db
    json sessions.all
  end

  post '/users', provides: :json do
    result = User.new.save(json_request)
    create_response(result)
  end

  post '/users/auth', provides: :json do
    result = User.new.auth(json_request)
    create_response(result, 401)
  end

  post '/users/auth/token', provides: :json do
    result = User.new.auth_token(json_request)
    create_response(result, 401)
  end
end
