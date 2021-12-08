require 'rest-client'
module Iam
  class Validator

    def self.validate(user_id, token, for_tenant_user = true)
      return nil unless user_id && token

      begin
        response = RestClient.get(SERVICE_IAM + "/v1/users/#{user_id}", { 'Authorization': "Bearer #{token}" }
        )
        raise(AuthExceptionHandler::SdAuthException, INTERNAL_SERVER_ERROR) if response.nil?

        user_data = JSON(response.body)
        if for_tenant_user && !user_data['createdBy'].nil?
            puts 'Only Tenant User can perform this action'
            raise(AuthExceptionHandler::SdAuthException, UNAUTHORISED)
        end
        { id: user_id, name: [user_data['firstName'],user_data['lastName']].join(' ') }
      rescue RestClient::Unauthorized
        puts 'Aunauthorised user'
        raise(AuthExceptionHandler::SdAuthException, UNAUTHORISED)
      rescue RestClient::NotFound, RestClient::BadRequest
        puts 'No user found with given access token'
        raise(AuthExceptionHandler::SdAuthException, INVALID_USER_DATA)
      rescue RestClient::InternalServerError
        puts 'Error while fetching user details'
        raise(AuthExceptionHandler::SdAuthException, INTERNAL_SERVER_ERROR)
      end
    end
  end
end   