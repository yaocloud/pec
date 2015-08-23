require 'fog'
require 'ip'
require 'colorator'
require "pec/version"
require "pec/logger"
require "pec/configure"
require "pec/director"
require "pec/handler"
require "pec/cli"

module Pec
  def self.compute
    @_compute ||= Fog::Compute.new({
      provider: 'openstack'
    })
    @_compute
  end
  
  def self.neutron
    @_neutron ||= Fog::Network.new({
      provider: 'openstack'
    })
    @_neutron
  end
  
  def self.identity
    @_identity ||= Fog::Identity.new({
      provider: 'openstack'
    })
    @_identity
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
