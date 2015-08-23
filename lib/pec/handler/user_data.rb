module Pec::Handler
  class UserData < Base
    self.kind = 'user_data'
    class << self
      def build(host) 
        user_data = host.user_data || {}
        user_data['fqdn'] = host.name if host.user_data && !host.user_data['fqdn'] 
        { user_data: user_data }
      end
    end
  end
end

