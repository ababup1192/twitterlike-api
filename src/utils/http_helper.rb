require 'json'
require 'sinatra/json'

# HttpHelper Module
module HttpHelper
  def json_request
    JSON.parse(request.body.read, symbolize_names: true)
  end

  def create_response(result, error_code = 400)
    status, message = result
    case status
    when :ok
      cross_origin
      json message
    when :error
      status(error_code)
      json message
    end
  end
end
