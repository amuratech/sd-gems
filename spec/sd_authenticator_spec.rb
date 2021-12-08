require_relative 'spec_helper.rb'
require_relative '../lib/sd_authenticator.rb'
require_relative '../lib/iam/tenant_service.rb'
require_relative '../lib/iam/validator.rb'

RSpec.describe SdAuthenticator do
  describe '#authenticate' do
      let(:token){"eyJhbGciOiJub25lIn0.eyJpc3MiOiJzZWxsIiwiZGF0YSI6eyJleHBpcnkiOjE2Mzg5NjU0MTEsInVzZXJJZCI6IjQ5NDUiLCJ0ZW5hbnRJZCI6IjIzMDgiLCJleHBpcmVzSW4iOjE2Mzg5NjU0MTEsInRva2VuVHlwZSI6ImJlYXJlciIsImFjY2Vzc1Rva2VuIjoiNzM0MmFkZTgtODU4Yi00YzcxLTk3YTgtOGQ0OWRhMWUzYWE0IiwidXNlcm5hbWUiOiJ0b255QHN0YXJrLmNvbSIsInBlcm1pc3Npb25zIjpbeyJpZCI6MTIsIm5hbWUiOiJ1c2VyIiwiZGVzY3JpcHRpb24iOiJoYXMgYWNjZXNzIHRvIHVzZXIiLCJsaW1pdHMiOi0xLCJ1bml0cyI6ImNvdW50IiwiYWN0aW9uIjp7InJlYWQiOnRydWUsIndyaXRlIjp0cnVlLCJ1cGRhdGUiOnRydWUsImRlbGV0ZSI6dHJ1ZSwiZW1haWwiOmZhbHNlLCJtZWV0aW5nIjpmYWxzZSwiY2FsbCI6ZmFsc2UsInNtcyI6ZmFsc2UsInRhc2siOmZhbHNlLCJub3RlIjpmYWxzZSwicmVhZEFsbCI6ZmFsc2UsInVwZGF0ZUFsbCI6dHJ1ZSwiZGVsZXRlQWxsIjpmYWxzZX19XX19."}

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
            expect(auth_data.user_id).to eq(4945)
            expect(auth_data.access_token).to eq('7342ade8-858b-4c71-97a8-8d49da1e3aa4')
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