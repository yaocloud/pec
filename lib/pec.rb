require 'pp'
require 'base64'
require 'yao'
require 'yaml'
require 'thor'
require 'ip'
require 'colorator'
require "pec/core"
require "pec/version"
require "pec/logger"
require "pec/configure"
require "pec/handler"
require "pec/coordinate"
require "pec/command"
require "pec/sample"
require "pec/init"
require "pec/cli"

module Pec
  def self.init_yao(_tenant_name)
    return unless reload_yao?(_tenant_name)
    check_env
    Yao.configure do
      auth_url "#{ENV["OS_AUTH_URL"]}/tokens"
      username ENV["OS_USERNAME"]
      password ENV["OS_PASSWORD"]
      tenant_name _tenant_name
    end
  end

  def self.reload_yao?(_tenant_name)
    @_last_tenant = _tenant_name if _tenant_name != @_last_tenant
  end

  def self.load_config(config_name=nil)
    @_configure ||= []
    config_name ||= 'Pec.yaml'
    merge_config(config_name).to_hash.reject {|k,v| k[0].match(/\_/) || k.match(/^includes$/) }.each do |host|
      @_configure << Pec::Configure.new(host)
    end
  end

  def self.merge_config(config_name)
    base_config = YAML.load_file(config_name)
    if include_files = base_config.to_hash.find{|k,v| k.match(/^includes$/) && !v.nil? }
      YAML.load(File.read(config_name) + include_files[1].map {|f|File.read(f)}.join("\n"))
    else
      base_config
    end
  end

  def self.configure
    load_config unless @_configure
    @_configure
  end

  def self.servers(hosts, options, fetch=false)
    self.configure.each do |config|
      next if hosts.size > 0 && hosts.none? {|name| config.name.match(/^#{name}/)}
      Pec.init_yao(config.tenant)
      server = Yao::Server.list_detail("name" => config.name).first if fetch
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

  def self.config_reset
    @_configure = nil
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

