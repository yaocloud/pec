require 'active_support/core_ext/string/inflections'
require 'fog'
module Noah
  module Query
    @@_list = Hash.new
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
      @@_list[name] || get_adapter.send("list_#{name}").data[:body][name]
    end

    def fetch(name)
      list.find {|s| s["name"] == name}
    end

    def get_ref(name)
      response = fetch(name)
      response["links"][0]["href"]
    end
  end
end
