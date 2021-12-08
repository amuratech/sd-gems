require 'rest-client'

module User
  class TenantService
      def self.fetch_details token
          return nil unless token
          begin
              response = RestClient.get(SERVICE_IAM + "/v1/tenants", { 'Authorization': "Bearer #{token}" }
              )
              raise(ExceptionHandler::SdAuthException, INVALID_DATA) if response.empty?
      
              JSON(response.body)
          rescue RestClient::Unauthorized
              puts 'Aunauthorised user'
              raise(ExceptionHandler::SdAuthException, UNAUTHORISED)
          rescue RestClient::NotFound, RestClient::BadRequest, JSON::ParserError
              puts 'No tenant found with given access token'
              raise(ExceptionHandler::SdAuthException, INVALID_TENANT_DATA)
          rescue RestClient::InternalServerError
              puts 'Error while fetching tenant details'
              raise(ExceptionHandler::SdAuthException, INTERNAL_SERVER_ERROR)
          end
      end
  end
end   