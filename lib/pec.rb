require 'pp'
require 'base64'
require 'yao'
require 'yaml'
require 'thor'
require 'ip'
require 'colorator'
require "pec/version"
require "pec/logger"
require "pec/configure"
require "pec/handler"
require "pec/command"
require "pec/sample"
require "pec/init"
require "pec/cli"


module Pec
  def self.init_yao(_tenant_name=nil)
    check_env
    Yao.configure do
      auth_url "#{ENV["OS_AUTH_URL"]}/tokens"
      username ENV["OS_USERNAME"]
      password ENV["OS_PASSWORD"]
      tenant_name _tenant_name || ENV["OS_TENANT_NAME"]
    end
  end

  def self.load_config(file_name=nil)
    file_name ||= 'Pec.yaml'
    @_configure = []
    YAML.load_file(file_name).to_hash.reject {|c| c[0].to_s.match(/^_/)}.each do |host|
      @_configure << Pec::Configure.new(host)
    end
  end

  def self.configure
    load_config unless @_configure
    @_configure
  end

  def self.servers(hosts)
    self.configure.each do |config|
      next if hosts.size > 0 && hosts.none? {|name| config.name.match(/^#{name}/)}
      Pec.init_yao(config.tenant)
      server = Yao::Server.list_detail.find {|s|s.name == config.name}
      yield(server, config)
    end
  end


  def self.check_env
    %w(
      OS_AUTH_URL
      OS_USERNAME
      OS_PASSWORD
    ).each do |name|
      raise "please set env #{name}" unless ENV[name]
    end
  end
end

class ::Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge(second.to_h, &merger)
  end

  def deep_merge!(second)
    self.merge!(deep_merge(second))
  end
end
