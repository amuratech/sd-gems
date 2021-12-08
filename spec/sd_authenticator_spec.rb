require_relative 'spec_helper.rb'
require_relative '../lib/sd_authenticator.rb'
require_relative '../lib/iam/tenant_service.rb'
require_relative '../lib/iam/validator.rb'

RSpec.describe SdAuthenticator do
  describe '#authenticate' do
      let(:token){"eyJhbGciOiJub25lIn0.eyJpc3MiOiJzZWxsIiwiZGF0YSI6eyJleHBpcnkiOjE2Mzg5NTE0OTksInVzZXJJZCI6MSwidGVuYW50SWQiOjIsImV4cGlyZXNJbiI6MTYzODk1MTQ5OSwidG9rZW5UeXBlIjoiYmVhcmVyIiwiYWNjZXNzVG9rZW4iOiJjNTY3YWFhOC04N2RkLTQ3YmYtYTcyMS01MmZjZTJkODNjN2EiLCJ1c2VybmFtZSI6InRvbnlAc3RhcmsuY29tIiwicGVybWlzc2lvbnMiOlt7ImlkIjoxMiwibmFtZSI6InVzZXIiLCJkZXNjcmlwdGlvbiI6ImhhcyBhY2Nlc3MgdG8gdXNlciIsImxpbWl0cyI6LTEsInVuaXRzIjoiY291bnQiLCJhY3Rpb24iOnsicmVhZCI6dHJ1ZSwid3JpdGUiOnRydWUsInVwZGF0ZSI6dHJ1ZSwiZGVsZXRlIjp0cnVlLCJlbWFpbCI6ZmFsc2UsIm1lZXRpbmciOmZhbHNlLCJjYWxsIjpmYWxzZSwic21zIjpmYWxzZSwidGFzayI6ZmFsc2UsIm5vdGUiOmZhbHNlLCJyZWFkQWxsIjpmYWxzZSwidXBkYXRlQWxsIjp0cnVlLCJkZWxldGVBbGwiOmZhbHNlfX1dfX0."}

      context 'with no tenant or user classes are defined' do
          it 'should raise invalid token error' do
              expect { SdAuthenticator.authenticate "Authorization #{token}" }.to raise_error(ExceptionHandler::SdAuthException, INVALID_TOKEN)
          end
      end

      context 'with  tenant and user classes are defined' do
          before(:each) do
              class Tenant
                def self.update_record some_arg
                end
              end

              class User
                def self.update_record some_arg
                  { id: 1, name: 'Tony Stark' }
                end
              end

              allow(Iam::TenantService).to receive(:fetch_details)
              allow(Iam::Validator).to receive(:validate).and_return(
                { id: 1, name: 'Tony Stark' }
              )
          end
          it 'should return Auth Data' do
            auth_data = SdAuthenticator.authenticate "Authorization #{token}"
            expect(auth_data.user_id).to eq(1)
            expect(auth_data.access_token).to eq('c567aaa8-87dd-47bf-a721-52fce2d83c7a')
            expect(auth_data.permissions.first.id).to eq(12)
            expect(auth_data.as_json['permissions'].first['action']).to match(
              {
              'read' => true,
              'write' => true,
              'update' => true,
              'delete' => true,
              'email' => false,
              'meeting' => false,
              'call' => false,
              'sms' => false,
              'task' => false,
              'note' => false,
              'read_all' => false,
              'update_all' => true,
              'delete_all' => false
              }
            )
          end
      end
  end
end