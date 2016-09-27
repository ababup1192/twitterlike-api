require 'sinatra'
require 'sinatra/reloader'
require 'json'
require_relative 'utils/http_helper'
require_relative 'entity/user'
require_relative 'entity/session'

# Sinatra Main controller
class UserRouter < Sinatra::Base
  include HttpHelper

  get '/users' do
    users = User.new.db
    users.all.to_json
  end

  get '/users/:id' do
    result = User.new.find(id: params[:id].to_i)
    create_response(result)
  end

  get '/sessions' do
    sessions = Session.new.db
    sessions.all.to_json
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
