require 'jwt'
require 'underscorize_keys'

module Auth
  class TokenParser
    def self.parse(token)
      begin
        decoded_token = JWT.decode(token, nil, false)[0]
        raise ExceptionHandler::SdAuthException unless decoded_token && decoded_token['data']

        Auth::Data.new(decoded_token) 
      rescue JWT::DecodeError => e
        puts "Error while parsing JWT token : #{e.message}"
        raise ExceptionHandler::SdAuthException
      end
    end
  end
end