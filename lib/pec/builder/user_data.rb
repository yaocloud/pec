module Pec
  module Builder
    class UserData
      def build(host, port_user_data) 
          user_data = default(host)
          user_data["write_files"] = port_user_data if port_user_data
          if template = load_template(host)
            user_data.deep_merge!(template) 
          end 
          { user_data: "#cloud-config\n" + user_data.to_yaml }
      end

      def load_template(host)
        host.templates.inject({}) do |merge_template, template|
          template.to_s.concat('.yaml') unless template.to_s.match(/.*\.yaml/)
          raise "#{template} not fond!" unless FileTest.exist?("user_data/#{template}")
          merge_template.deep_merge!(YAML.load_file("user_data/#{template}").to_hash)
        end if host.templates
      end 

      def default(host)
        _def = host.user_data || {}
        _def['fqdn'] = host.name if host.user_data && !host.user_data['fqdn'] 
        _def
      end
    end
  end
end

class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
        self.merge(second.to_h, &merger)
    end
    def deep_merge!(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
        self.merge!(second.to_h, &merger)
    end
end
