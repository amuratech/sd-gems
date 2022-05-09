require_relative '../spec_helper.rb'
require_relative '../../lib/auth/data.rb'
require_relative '../../lib/auth/token_parser.rb'

RSpec.describe Auth::Data,type: :model do

  before do
    @auth_data = Auth::TokenParser.parse("eyJhbGciOiJub25lIn0.eyJpc3MiOiJzZWxsIiwiZGF0YSI6eyJleHBpcnkiOjE2Mzg5NjU0MTEsInVzZXJJZCI6IjQ5NDUiLCJ0ZW5hbnRJZCI6IjIzMDgiLCJleHBpcmVzSW4iOjE2Mzg5NjU0MTEsInRva2VuVHlwZSI6ImJlYXJlciIsImFjY2Vzc1Rva2VuIjoiNzM0MmFkZTgtODU4Yi00YzcxLTk3YTgtOGQ0OWRhMWUzYWE0IiwidXNlcm5hbWUiOiJ0b255QHN0YXJrLmNvbSIsInBlcm1pc3Npb25zIjpbeyJpZCI6MTIsIm5hbWUiOiJ1c2VyIiwiZGVzY3JpcHRpb24iOiJoYXMgYWNjZXNzIHRvIHVzZXIiLCJsaW1pdHMiOi0xLCJ1bml0cyI6ImNvdW50IiwiYWN0aW9uIjp7InJlYWQiOnRydWUsIndyaXRlIjp0cnVlLCJ1cGRhdGUiOnRydWUsImRlbGV0ZSI6dHJ1ZSwiZW1haWwiOmZhbHNlLCJtZWV0aW5nIjpmYWxzZSwiY2FsbCI6ZmFsc2UsInNtcyI6ZmFsc2UsInRhc2siOmZhbHNlLCJub3RlIjpmYWxzZSwicmVhZEFsbCI6ZmFsc2UsInVwZGF0ZUFsbCI6dHJ1ZSwiZGVsZXRlQWxsIjpmYWxzZX19XX19.")
  end

  describe 'validations' do

    context 'with valid data' do
      it 'should be valid' do
        expect(@auth_data.access_token).to eq('7342ade8-858b-4c71-97a8-8d49da1e3aa4')
        expect(@auth_data.user_id).to eq(4945)
        expect(@auth_data.tenant_id).to eq(2308)
      end
    end

    context 'with invalid data' do
        it "should throw invalid_token exception" do
            options = {
                "data"=> {
                  "expiresIn"=> 3600,
                  "accessToken"=> "7342ade8-858b-4c71-97a8-8d49da1e3aa4",
                  "expiry"=> 1638859073,
                  "tokenType"=> "Bearer",
                  "userId"=> '4945',
                  "username"=> 'user1',
                  "tenantId"=> '2308',
                  "permissions"=> [
                    {
                      "name"=> "lead",
                      "description"=> nil,
                      "limits"=> -1,
                      "units"=> "count",
                      "action"=> {
                        "read"=> true,
                        "readAll"=> true,
                        "call"=> true,
                        "quote" => true
                      }
                    }
                  ]
                }
              }
            %w{expiresIn accessToken expiry tokenType userId tenantId permissions}.each do |attr|
                expect{ Auth::Data.new({ 'data'=> options['data'].except(attr)})}.to raise_error(AuthExceptionHandler::SdAuthException, INVALID_TOKEN)
            end
        end
    end

    context 'with invalid permissions' do
        it "should throw invalid_token exception" do
            options = {
                "data"=> {
                  "expiresIn"=> 3600,
                  "accessToken"=> "7342ade8-858b-4c71-97a8-8d49da1e3aa4",
                  "expiry"=> 1638859073,
                  "tokenType"=> "Bearer",
                  "userId"=> '4945',
                  "username"=> 'user1',
                  "tenantId"=> '2308',
                  "permissions"=> [
                    {
                      "name"=> "lead",
                      "description"=> "has access to lead resource",
                      "limits"=> -1,
                      "units"=> "count",
                      "action"=> {
                        "read"=> true,
                        "readAll"=> true,
                        "quote" => false
                      }
                    }
                  ]
                }
              }
            options['data']['permissions'].first['action']['unkonwn'] = true
            expect{ Auth::Data.new(options)}.not_to raise_error(AuthExceptionHandler::SdAuthException, INVALID_TOKEN)
        end
    end
  end

  describe 'instance_methods' do
    context 'without permission name' do
      it 'should return false' do
        expect(@auth_data.can_access?(nil)).to be_falsey
      end
    end

    context 'with permission name' do
      it 'should return true if user have access' do
        expect(@auth_data.can_access?('user', 'read')).to be_truthy
      end
      it 'should return false if user have access' do
        expect(@auth_data.can_access?('user', 'delete_all')).to be_falsey
      end
    end
  end
end
