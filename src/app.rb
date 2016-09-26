require 'sinatra'
require 'sinatra/reloader'
require 'json'
require_relative 'user'

# Sinatra Main controller
class MainApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    'index'
  end
  get '/user' do
    users = User.new.db
    users.all.to_json
  end
  post '/user', provides: :json do
    json_hash = JSON.parse(request.body.read, symbolize_names: true)
    status, message = User.new.save(json_hash)
    case status
    when :ok
      message
    when :error
      status(400)
      message
    end
  end
  post '/user/auth', provides: :json do
    json_hash = JSON.parse(request.body.read, symbolize_names: true)
    status, message = User.new.auth(json_hash)
    case status
    when :ok
      true
    when :error
      status(400)
      message
    end
  end
end
