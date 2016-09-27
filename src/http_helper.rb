# HttpHelper Module
module HttpHelper
  def json_request
    JSON.parse(request.body.read, symbolize_names: true)
  end

  def create_response(result, error_code = 400)
    status, message = result
    case status
    when :ok
      message
    when :error
      status(error_code)
      message
    end
  end
end
