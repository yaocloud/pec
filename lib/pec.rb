require 'pp'
require 'base64'
require 'yao'
require 'yaml'
require 'thor'
require 'ip'
require 'colorator'
require "pec/core"
require "pec/config_file"
require "pec/version"
require "pec/logger"
require "pec/configure"
require "pec/handler"
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

  def self.load_config(config_name="Pec.yaml")
    @_configure ||= []
    ConfigFile.new(config_name).load.to_hash.reject {|k,v| k[0].match(/\_/) || k.match(/^includes$/) }.each do |host|
      @_configure << Pec::Configure.new(host)
    end
  rescue => e
    Pec::Logger.critical "configure error!"
    raise e
  end

  def self.configure
    load_config unless @_configure
    @_configure
  end

  def self.servers(hosts, options, not_fetch)
    self.configure.each do |config|
      next if hosts.size > 0 && hosts.none? {|name| config.name.match(/^#{name}/)}
      Pec.init_yao(config.tenant)
      server = fetch_server(config) unless not_fetch
      yield(server, config)
    end
  end

  def self.fetch_server(config)
    server_list(config).find {|s|s.name == config.name}
  end

  def self.fetch_tenant_by_id(server)
    tenant_list.find {|tenant| tenant.id == server.tenant_id}
  end

  def self.fetch_tenant_by_name(config)
    tenant_list.find {|tenant| tenant.name == config.tenant}
  end

  def self.fetch_flavor(server)
    flavor_list(server).find {|f|f.id == server.flavor['id']}
  end

  def self.server_list(config)
    @_server_list ||= {}
    @_server_list[config.tenant] ||= Yao::Server.list_detail({tenant_id: fetch_tenant_by_name(config).id})
  end

  def self.tenant_list
    @_tenant_list ||= Yao::Tenant.list
  end

  def self.flavor_list(server)
    @_flavor_list ||= {}
    @_flavor_list[server.tenant_id] ||= Yao::Flavor.list
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

