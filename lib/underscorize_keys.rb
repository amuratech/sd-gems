class UnderscorizeKeys
    def self.do data
      return unless data.is_a? Hash
      data.transform_keys! &:to_s
      data.transform_keys!{ |k| k.gsub(/(.)([A-Z])/,'\1_\2').downcase }
      data.each do |x,y|
        if y.is_a? Hash
          self.do(y)
        elsif y.is_a? Array
          y.each{|z| self.do(z) if z.is_a?(Hash)}
        end
      end
    end
end