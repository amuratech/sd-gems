require 'auth/token_parser'
require 'auth/data'
require 'auth_exception_handler/sd_auth_exception'
require 'iam/tenant_service.rb'
require 'iam/validator.rb'
require 'constants.rb'

class SdAuthenticator

  # options: authorization_header: string, for_tenant_user: boolean, fetch_tenant: boolean
  def self.authenticate options
    raise(AuthExceptionHandler::SdAuthException, INVALID_TOKEN) unless (Object.const_defined?('Tenant') && Object.const_defined?('User')) || options[:authorization_header].nil?
    token = http_auth_header(options[:authorization_header])
    auth_data = Auth::TokenParser.parse(token)
    
    # Tenant.update_record will find or initialize and update according to details
    Tenant.update_record(Iam::TenantService.fetch_details(token)) if options[:fetch_tenant]
    user = User.get_by_id(auth_data.user_id)
    unless user
      user_data = Iam::Validator.validate(auth_data.user_id, token, options[:for_tenant_user])
      user_data[:tenant_id] = auth_data.tenant_id
      # User.update_record will find or initialize and update according to details
      user = User.update_record(user_data)
      raise(AuthExceptionHandler::SdAuthException, INVALID_TOKEN) unless user
    end
    thread = Thread.current
    thread[:user] = user
    thread[:token] = token
    auth_data
  end

  def self.http_auth_header(headers)
    return headers.split(' ').last unless headers.empty?

    raise(AuthExceptionHandler::SdAuthException, INVALID_TOKEN)
  end

  private_class_method :http_auth_header
end