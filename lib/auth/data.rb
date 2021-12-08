require "json-schema"

module Auth
  class Data  
    attr_accessor(
      :expires_in,
      :access_token,
      :expiry,
      :token_type,
      :user_id,
      :username,
      :tenant_id,
      :permissions
    )

    def initialize options = {}
      begin 
       JSON::Validator.validate!(File.read(File.join(File.dirname(__FILE__), 'token-schema.json')), options)
      rescue JSON::Schema::ValidationError => e
        raise(ExceptionHandler::SdAuthException, INVALID_TOKEN)
        puts "==Invalid auth data: #{e.message}=="
      end
      options = options['data']
      UnderscorizeKeys.do(options)
      [:expires_in, :access_token, :expiry, :token_type, :user_id, :username, :tenant_id].each{|attr| send("#{attr}=", options[attr.to_s])}
      @permissions = JSON.parse(options['permissions'].to_json, object_class: OpenStruct)
    end

    def can_access? permission_name, action_name = 'read'
      return false unless permission_name
      return true unless permissions.select{ |permission| permission.name == permission_name && permission.action[action_name]}.empty?
      return false
    end

    def user_id
      @user_id = @user_id.to_i unless @user_id.nil?
    end

    def tenant_id
      @tenant_id = @tenant_id.to_i unless @tenant_id.nil?
    end

    def as_json
      json = {}
      %w{expires_in access_token expiry token_type user_id tenant_id}.each{|c| json[c] = send(c.to_sym) }
      json['permissions'] = permissions.map{|permission| h = permission.to_h; h[:action] = h[:action].to_h.transform_keys(&:to_s); h.transform_keys(&:to_s)}
      json
    end

  end
end