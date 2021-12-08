require_relative '../spec_helper.rb'
require_relative '../../lib/auth/data.rb'
require_relative '../../lib/auth/token_parser.rb'

RSpec.describe Auth::Data,type: :model do

  before do
    @auth_data = Auth::TokenParser.parse("eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7ImFjY2Vzc1Rva2VuIjoiMWM3N2MzMmYtNWY1Yi00MzQyLTkxYjItOTYxZTM4MDQ1NDk4IiwiZXhwaXJlc0luIjozNjAwLCJleHBpcnkiOjE2Mzg4NTkwNzMsInVzZXJJZCI6NDk0NSwidGVuYW50SWQiOjIzMDgsInRva2VuVHlwZSI6IkJlYXJlciIsInBlcm1pc3Npb25zIjpbeyJuYW1lIjoibGVhZCIsImRlc2NyaXB0aW9uIjoiaGFzIGFjY2VzcyB0byBsZWFkIHJlc291cmNlIiwibGltaXRzIjotMSwidW5pdHMiOiJjb3VudCIsImFjdGlvbiI6eyJyZWFkIjp0cnVlLCJyZWFkQWxsIjp0cnVlfX0seyJuYW1lIjoiZGVhbCIsImRlc2NyaXB0aW9uIjoiaGFzIGFjY2VzcyB0byBkZWFsIHJlc291cmNlIiwibGltaXRzIjotMSwidW5pdHMiOiJjb3VudCIsImFjdGlvbiI6eyJyZWFkIjp0cnVlLCJyZWFkQWxsIjp0cnVlfX0seyJuYW1lIjoidXNlciIsImRlc2NyaXB0aW9uIjoiaGFzIGFjY2VzcyB0byB1c2VyIHJlc291cmNlIiwibGltaXRzIjotMSwidW5pdHMiOiJjb3VudCIsImFjdGlvbiI6eyJyZWFkIjp0cnVlLCJyZWFkQWxsIjp0cnVlfX0seyJuYW1lIjoiY29udGFjdCIsImRlc2NyaXB0aW9uIjoiaGFzIGFjY2VzcyB0byB1c2VyIHJlc291cmNlIiwibGltaXRzIjotMSwidW5pdHMiOiJjb3VudCIsImFjdGlvbiI6eyJyZWFkIjp0cnVlLCJyZWFkQWxsIjp0cnVlfX0seyJuYW1lIjoiZW1haWxfdGVtcGxhdGUiLCJkZXNjcmlwdGlvbiI6ImhhcyBhY2Nlc3MgdG8gdXNlciByZXNvdXJjZSIsImxpbWl0cyI6LTEsInVuaXRzIjoiY291bnQiLCJhY3Rpb24iOnsicmVhZCI6dHJ1ZSwicmVhZEFsbCI6dHJ1ZX19XX19.2cn0uwjLVr3wP0PIiQKUHeWUUvcjdG_WZzr6Q6ff5Co")
  end

  describe 'validations' do

    context 'with valid data' do
      it 'should be valid' do
        expect(@auth_data.access_token).to eq('1c77c32f-5f5b-4342-91b2-961e38045498')
        expect(@auth_data.user_id).to eq(4945)
        expect(@auth_data.tenant_id).to eq(2308)
      end
    end

    context 'with invalid data' do
        it "should throw invalid_token exception" do
            options = {
                "data"=> {
                  "expiresIn"=> 3600,
                  "accessToken"=> "1c77c32f-5f5b-4342-91b2-961e38045498",
                  "expiry"=> 1638859073,
                  "tokenType"=> "Bearer",
                  "userId"=> 4945,
                  "username"=> 'user1',
                  "tenantId"=> 2308,
                  "permissions"=> [
                    {
                      "name"=> "lead",
                      "description"=> "has access to lead resource",
                      "limits"=> -1,
                      "units"=> "count",
                      "action"=> {
                        "read"=> true,
                        "readAll"=> true,
                        "call"=> true
                      }
                    }
                  ]
                }
              }
            %w{expiresIn accessToken expiry tokenType userId tenantId permissions}.each do |attr|
                expect{ Auth::Data.new({ 'data'=> options['data'].except(attr)})}.to raise_error(ExceptionHandler::SdAuthException, INVALID_TOKEN)
            end
        end
    end

    context 'with invalid permissions' do
        it "should throw invalid_token exception" do
            options = {
                "data"=> {
                  "expiresIn"=> 3600,
                  "accessToken"=> "1c77c32f-5f5b-4342-91b2-961e38045498",
                  "expiry"=> 1638859073,
                  "tokenType"=> "Bearer",
                  "userId"=> 4945,
                  "username"=> 'user1',
                  "tenantId"=> 2308,
                  "permissions"=> [
                    {
                      "name"=> "lead",
                      "description"=> "has access to lead resource",
                      "limits"=> -1,
                      "units"=> "count",
                      "action"=> {
                        "read"=> true,
                        "readAll"=> true,
                      }
                    }
                  ]
                }
              }
            options['data']['permissions'].first['action']['unkonwn'] = true
            expect{ Auth::Data.new(options)}.to raise_error(ExceptionHandler::SdAuthException, INVALID_TOKEN)
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
