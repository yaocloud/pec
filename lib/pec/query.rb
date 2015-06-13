require 'active_support/core_ext/string/inflections'
module Pec
  module Query
    def list
      class_name = self.name.demodulize.downcase
      Pec::Resource.get.send("#{class_name}_list")
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
