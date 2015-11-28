require 'erb'
module Pec
  class ConfigFile
    attr_accessor :config_name
    def initialize(config_name)
      self.config_name = File.exist?("#{config_name}.erb") ? "#{config_name}.erb" : config_name
    end

    def load
      base = read_file(config_name)
      include_files = YAML.load(base).to_hash.find{|k,v| k.match(/^includes$/) && !v.nil? }
      inc = include_files ? include_files[1].map {|f| read_file(f)}.join("\n") : ""
      YAML.load(base + inc)
    end

    def read_file(file_name)
      if File.exist?(file_name)
        case
          when file_name.match(/.erb$/)
            erb = ERB.new(File.read(file_name), nil, '%-')
            erb.result
          when file_name.match(/.yaml$/) || file_name.match(/.yml$/)
            File.read(file_name)
          else
            raise "not match file type must be yaml or erb"
        end
      else
        raise "not file exiets! #{file_name}"
      end
    end
  end
end
