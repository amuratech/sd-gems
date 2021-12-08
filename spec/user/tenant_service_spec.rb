require_relative '../spec_helper.rb'
require_relative '../../lib/iam/tenant_service.rb'

RSpec.describe Iam::TenantService do
  describe '#fetch_details' do

    context 'With valid fetch tenant request' do
      before do
        stub_request(:get, "http://localhost:8081/v1/tenants").
         with(
           headers: {
          'Authorization'=>'Bearer some-token'
           }).
         to_return(status: 200, body: { "id": 1, "accountName": "My Company", "website": "http://www.google.com" }.to_json, headers: {})
      end

      it 'should return nil if no tenant passed' do
        expect(Iam::TenantService.fetch_details(nil)).to equal(nil)
      end

      it 'should return nil if no tenant passed' do
        expect(Iam::TenantService.fetch_details(nil)).to equal(nil)
      end

      it 'should return tenant with name if tenant id and token present' do
        resp = Iam::TenantService.fetch_details('some-token')
        expect(resp['accountName']).to match('My Company')
        expect(resp['website']).to match('http://www.google.com')
      end
    end

    context 'when tenant no data returned' do
      before do
        stub_request(:get, "http://localhost:8081/v1/tenants").
         with(
           headers: {
          'Authorization'=>'Bearer incorrect-token'
           }).to_return(status: 200, body: "", headers: {})
      end
      it 'should throw invalid_tenant_details error' do
        expect{ Iam::TenantService.fetch_details('incorrect-token') }.to raise_error(ExceptionHandler::SdAuthException, INVALID_DATA)
      end
    end

    context 'With unauthorised fetch user request' do
      before do
        stub_request(:get, "http://localhost:8081/v1/tenants").
         with(
           headers: {
          'Authorization'=>'Bearer incorrect-token'
           }).to_return(status: 401)
      end
      it 'should throw Authentication error' do
        expect{ Iam::TenantService.fetch_details('incorrect-token') }.to raise_error(ExceptionHandler::SdAuthException, UNAUTHORISED)
      end
    end

    context 'With runtime Error at iam service' do
      before do
        stub_request(:get, "http://localhost:8081/v1/tenants").
         with(
           headers: {
          'Authorization'=>'Bearer correct-token'
           }).to_return(status: 500)
      end
      it 'should throw InternalServerError error' do
        expect{ Iam::TenantService.fetch_details('correct-token') }.to raise_error(ExceptionHandler::SdAuthException, INTERNAL_SERVER_ERROR)
      end
    end
  end
end
