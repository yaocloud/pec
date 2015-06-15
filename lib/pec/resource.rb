require 'singleton'
module Pec
  class Resource
    include Singleton
    class << self
      @@_resource = {}
      @@_tenant = nil
      def get
        raise(Pec::Errors::Resource, "Please be tenant is always set") unless @@_tenant
        unless ENV['PEC_TEST']
          @@_resource[@@_tenant] ||= Pec::Resource::OpenStack.new(@@_tenant)
        else
          @@_resource[@@_tenant] ||= Pec::Resource::Mock.new(@@_tenant)
        end
      end

      def set_tenant(tenant)
        @@_tenant = tenant
      end
    end
  end
end
