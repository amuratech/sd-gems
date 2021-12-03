require_relative '../lib/underscorize_keys.rb'

RSpec.describe UnderscorizeKeys do
    describe '#do' do
      it 'returns underscore keys' do
        input = {'testKey' => 303, 'test_keyAgain' => 333, 'test_key_my' => 'asdnafsdf'}
        expect(UnderscorizeKeys.do(input)) == { 'test_key' => 303, 'test_key_again' => 333, 'test_key_my' => 'asdnafsdf'}
      end
      it 'updates nest hash as well' do
        input = {'testKey' => 303, 'test_keyAgain'=> {'testKey_lore' => 333, 'test_key_my' => 'asdnafsdf'}}
        expect(UnderscorizeKeys.do(input)) == { 'testKey' => 303, 'test_key_again' => {'test_key_lore' => 333, 'test_key_my' => 'asdnafsdf'} }
      end
      it 'updates nest hash with array as well' do
        input = {'testKey' => 303, 'test_keyAgain'=> [{'testKey_lore' => 333, 'test_key_my' => 'asdnafsdf'},{'testKeylore' => 333, 'test_key' => 'asdnafsdf'}]}
        expect(UnderscorizeKeys.do(input)) == { 'testKey' => 303, 'test_key_again' => [{'test_key_lore' => 333, 'test_key_my' => 'asdnafsdf'},{'test_keylore' => 333, 'test_key' => 'asdnafsdf'}] }
      end
    end
end