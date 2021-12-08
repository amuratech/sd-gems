require 'rest-client'

module Iam
  class TenantService
      def self.fetch_details token
          return nil unless token
          begin
              response = RestClient.get(SERVICE_IAM + "/v1/tenants", { 'Authorization': "Bearer #{token}" }
              )
              raise(AuthExceptionHandler::SdAuthException, INVALID_DATA) if response.empty?
      
              JSON(response.body)
          rescue RestClient::Unauthorized
              puts 'Aunauthorised user'
              raise(AuthExceptionHandler::SdAuthException, UNAUTHORISED)
          rescue RestClient::NotFound, RestClient::BadRequest, JSON::ParserError
              puts 'No tenant found with given access token'
              raise(AuthExceptionHandler::SdAuthException, INVALID_TENANT_DATA)
          rescue RestClient::InternalServerError
              puts 'Error while fetching tenant details'
              raise(AuthExceptionHandler::SdAuthException, INTERNAL_SERVER_ERROR)
          end
      end
  end
end   