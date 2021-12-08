require_relative '../spec_helper.rb'
require_relative '../../lib/user/validator.rb'

RSpec.describe User::Validator do
  describe '#validate' do

    context 'With valid fetch user request' do
      before do
        stub_request(:get, "http://localhost:8081/v1/users/1").
         with(
           headers: {
          'Authorization'=>'Bearer some-token'
           }).
         to_return(status: 200, body: { "id": 1, "firstName": "Jane","lastName": 'Doe', "createdBy": nil }.to_json, headers: {})
      end

      it 'should return nil if no user passed' do
        expect(User::Validator.validate(nil, nil)).to equal(nil)
      end

      it 'should return nil if no token passed' do
        expect(User::Validator.validate(1, nil)).to equal(nil)
      end

      it 'should return user with name if user id and token present' do
        user = User::Validator.validate(1, 'some-token')
        expect(user[:name]).to match('Jane Doe')
      end
    end

    context 'With valid fetch user request for Non-Tenant user' do
      before do
        stub_request(:get, "http://localhost:8081/v1/users/1").
         with(
           headers: {
          'Authorization'=>'Bearer some-token'
           }).
         to_return(status: 200, body: { "id": 1, "firstName": "Jane","lastName": 'Doe', "createdBy": 14 }.to_json, headers: {})
      end

      it 'should throw Authentication error' do
        expect{ User::Validator.validate(1, 'some-token') }.to raise_error(ExceptionHandler::SdAuthException, UNAUTHORISED)
      end

      it 'should not raise any error if validation not for_tenant_user' do
        user = User::Validator.validate(1, 'some-token', false)
        expect(user[:name]).to match('Jane Doe')
      end
    end

    context 'With unauthorised fetch user request' do
      before do
        stub_request(:get, "http://localhost:8081/v1/users/1").
         with(
           headers: {
          'Authorization'=>'Bearer incorrect-token'
           }).to_return(status: 401)
      end
      it 'should throw Authentication error' do
        expect{ User::Validator.validate(1, 'incorrect-token') }.to raise_error(ExceptionHandler::SdAuthException, UNAUTHORISED)
      end
    end

    context 'With unknown user id' do
      before do
        stub_request(:get, "http://localhost:8081/v1/users/1").
         with(
           headers: {
          'Authorization'=>'Bearer correct-token'
           }).to_return(status: 404)
      end
      it 'should throw InvalidDataError error' do
        expect{ User::Validator.validate(1, 'correct-token') }.to raise_error(ExceptionHandler::SdAuthException, INVALID_USER_DATA)
      end
    end

    context 'With runtime Error at iam service' do
      before do
        stub_request(:get, "http://localhost:8081/v1/users/1").
         with(
           headers: {
          'Authorization'=>'Bearer correct-token'
           }).to_return(status: 500)
      end
      it 'should throw InternalServerError error' do
        expect{ User::Validator.validate(1, 'correct-token') }.to raise_error(ExceptionHandler::SdAuthException, INTERNAL_SERVER_ERROR)
      end
    end
  end
end
