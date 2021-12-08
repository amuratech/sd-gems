require 'auth/token_parser'
require 'auth/data'
require 'exception_handler/sd_auth_exception'

class SdAuthenticator
  def authenticate token, authorization_header, for_tenant_user = true
    raise(ExceptionHandler::SdAuthException, INVALID_TOKEN) unless Object.const_defined?('Tenant') && Object.const_defined?('User')
    token = http_auth_header(authorization_header)
    auth_data = Auth::TokenParser.parse(token)
    
    # Tenant.update_record will find or initialize and update according to details
    Tenant.update_record(User::TenantService.fetch_details(token))
    user_data = User::Validator.validate(auth_data.user_id, token, for_tenant_user)
    user_data[:tenant_id] = auth_data.tenant_id
    # User.update_record will find or initialize and update according to details
    success = User.update_record(user_data)
    raise(ExceptionHandler::SdAuthException, INVALID_TOKEN) unless success
  
    thread = Thread.current
    thread[:user] = user
    thread[:token] = token
    auth_data
  end

  private
  def http_auth_header(headers)
    return headers.split(' ').last if headers.present?

    raise(ExceptionHandler::SdAuthException, INVALID_TOKEN)
  end
end