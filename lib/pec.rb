require 'fog'
require 'ip'
require 'colorator'
require "pec/version"
require "pec/query"
require "pec/errors"
require "pec/init"
require "pec/resource"
require "pec/resource/openstack"
require "pec/resource/mock"
require "pec/director"
require "pec/director/helper"
require "pec/director/make_director"
require "pec/director/destroy_director"
require "pec/director/vm_status_director"
require "pec/configure"
require "pec/configure/sample"
require "pec/configure/host"
require "pec/configure/ethernet"
require "pec/configure/user_data"
require "pec/compute/server"
require "pec/compute/flavor"
require "pec/compute/image"
require "pec/compute/tenant"
require "pec/network/security_group"
require "pec/network/port"
require "pec/network/port_state"
require "pec/network/subnet"
require "pec/cli"

module Pec
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
