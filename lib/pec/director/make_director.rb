module Pec
  class Director
    class MakeDirector
      def initialize(command_options)
          @flavor = Pec::Compute::Flavor.new
          @image = Pec::Compute::Image.new
          @compute = Pec::Compute::Server.new
          @subnet = Pec::Network::Subnet.new
          @security_group = Pec::Compute::Security_Group.new
      end

      def execute!(host)
        make(host)
      end

      def do_it?(host)
        true
      end

      def make(host)
        if @compute.exists?(host.name)
          puts "skip create server! name:#{host.name} is exists!"
          return true
        end

        ports = Pec::Director::Helper.ports_assign(host, @subnet, @security_group)
        flavor_ref = @flavor.get_ref(host.flavor)
        image_ref = @image.get_ref(host.image)
        options = { "user_data" => Pec::Configure::UserData.make(host, ports) }
        options.merge!(Pec::Director::Helper.get_nics(ports))

        @compute.create(host.name, image_ref, flavor_ref, options)
      end

      def err_message(e, host)
          puts e
          puts "can't create server:#{host.name}"
      end
    end
  end
end
