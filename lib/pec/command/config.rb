module Pec::Command
  class Config < Base
    def self.run(hosts, options)
      puts YAML.dump(
        YAML.load_file("Pec.yaml").to_hash.reject {|c|
          c[0].to_s.match(/^_/) || (hosts && hosts.none? {|name| c.match(/^#{name}/)})
        }
      )
      rescue => e
        print_exception(e)
    end
  end
end
