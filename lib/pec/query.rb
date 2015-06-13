require 'active_support/core_ext/string/inflections'
require 'fog'
module Pec
  module Query
    @@_list = {}
    def get_adapter
      case
      when self.class.name.include?('Network')
        Fog::Network[:openstack]
      when self.class.name.include?('Compute')
        Fog::Compute[:openstack]
      else
        raise
      end
    end

    def list
      name = self.class.name.demodulize.downcase+"s"
      @@_list ||= Hash.new
      @@_list[name] ||= get_adapter.send("list_#{name}").data[:body][name]
    end

    def fetch(name)
      list.find {|s| s["name"] == name}
    end

    def get_ref(name)
      class_name = self.class.name.demodulize.downcase
      response = fetch(name)
      raise(Pec::Errors::Query, "#{class_name}:#{name} ref is not fond!") unless response
      response["links"][0]["href"]
    end
  end
end
