require_relative 'spec_helper.rb'
require_relative '../lib/sd_authenticator.rb'
require_relative '../lib/iam/tenant_service.rb'
require_relative '../lib/iam/validator.rb'

RSpec.describe SdAuthenticator do
  describe '#authenticate' do
    let(:token){"eyJhbGciOiJub25lIn0.eyJpc3MiOiJzZWxsIiwiZGF0YSI6eyJleHBpcnkiOjE2Mzg5NjU0MTEsInVzZXJJZCI6IjQ5NDUiLCJ0ZW5hbnRJZCI6IjIzMDgiLCJleHBpcmVzSW4iOjE2Mzg5NjU0MTEsInRva2VuVHlwZSI6ImJlYXJlciIsImFjY2Vzc1Rva2VuIjoiNzM0MmFkZTgtODU4Yi00YzcxLTk3YTgtOGQ0OWRhMWUzYWE0IiwidXNlcm5hbWUiOiJ0b255QHN0YXJrLmNvbSIsInBlcm1pc3Npb25zIjpbeyJpZCI6MTIsIm5hbWUiOiJ1c2VyIiwiZGVzY3JpcHRpb24iOiJoYXMgYWNjZXNzIHRvIHVzZXIiLCJsaW1pdHMiOi0xLCJ1bml0cyI6ImNvdW50IiwiYWN0aW9uIjp7InJlYWQiOnRydWUsIndyaXRlIjp0cnVlLCJ1cGRhdGUiOnRydWUsImRlbGV0ZSI6dHJ1ZSwiZW1haWwiOmZhbHNlLCJtZWV0aW5nIjpmYWxzZSwiY2FsbCI6ZmFsc2UsInNtcyI6ZmFsc2UsInRhc2siOmZhbHNlLCJub3RlIjpmYWxzZSwicmVhZEFsbCI6ZmFsc2UsInVwZGF0ZUFsbCI6dHJ1ZSwiZGVsZXRlQWxsIjpmYWxzZX19XX19."}

    context 'with tenant class is not defined' do
      before(:each) do
        class User
          def self.update_record some_arg
            { id: 1, name: 'Tony Stark' }
          end

          def self.get_by_id id
            { id: 1, name: 'Tony Stark' }
          end
        end
        allow(Iam::Validator).to receive(:validate)
      end
      it 'should not validate tenant' do
        expect(Iam::TenantService).not_to receive(:fetch_details)
        SdAuthenticator.authenticate({ authorization_header: "Authorization #{token}"})
      end
    end

    context 'with user class is not defined' do
      before(:each) do
       allow(Iam::Validator).to receive(:validate).and_return(
            { id: 1, name: 'Tony Stark' }
          )
      end

      it 'should validate user' do
        auth_data = SdAuthenticator.authenticate({ authorization_header: "Authorization #{token}"})
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

    context 'with user and tenant classes defined' do
      before(:all) do
        class Tenant
          def self.update_record some_arg
          end

          def self.get_by_id id
            { id: 1, name: 'Tony Stark' }
          end
        end

        class User
          def self.update_record some_arg
            { id: 1, name: 'Tony Stark' }
          end

          def self.get_by_id id
            { id: 1, name: 'Tony Stark' }
          end
        end
      end

      context 'with user already exists' do
        it 'should return Auth Data' do
          expect(Iam::Validator).not_to receive(:validate)
          expect(Iam::TenantService).not_to receive(:fetch_details)
          auth_data = SdAuthenticator.authenticate({ authorization_header: "Authorization #{token}" })
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

      context 'when user does not exists' do
        before(:each) do
          allow(Iam::Validator).to receive(:validate).and_return(
            { id: 1, name: 'Tony Stark' }
          )
          allow(User).to receive(:get_by_id).and_return(nil)
        end
        it 'should return Auth Data' do
          expect(Iam::Validator).to receive(:validate)
          auth_data = SdAuthenticator.authenticate({ authorization_header: "Authorization #{token}" })
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

      context 'when tenant does not exist' do
        before(:each) do
          allow(Iam::Validator).to receive(:validate).and_return(
            { id: 1, name: 'Tony Stark' }
          )
          allow(Iam::TenantService).to receive(:fetch_details).and_return({ id: 99, name: 'Tenant99' })
          allow(User).to receive(:get_by_id).and_return(nil)
          allow(Tenant).to receive(:get_by_id).and_return(nil)
          allow(Tenant).to receive(:update_record)
        end
        it 'should return Auth Data' do
          expect(Iam::Validator).to receive(:validate)
          expect(Tenant).to receive(:update_record).with({ id: 99, name: 'Tenant99' })
          auth_data = SdAuthenticator.authenticate({ authorization_header: "Authorization #{token}" })
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
end
