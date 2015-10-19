module Pec::Command
  class Config < Base
    def self.run(host_name, options)
      puts YAML.dump(
        YAML.load_file("Pec.yaml").to_hash.reject {|c| c[0].to_s.match(/^_/)}
      )
      rescue => e
        print_exception(e)
    end
  end
end
