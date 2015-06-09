require 'spec_helper'

describe Pec::Configure do
    describe 'standard p1' do
      before do
        @configure = Pec::Configure.new
        @configure.load("spec/fixture/in/pec_configure_starndard_p1.yaml")
      end
      it 'load' do
        members = [:@name, :@image, :@flavor, :@security_group, :@user_data, :@networks, :@templates]
        @configure.each do |host|
          expect(host.instance_variables.all? {|val| members.include?(val) }).to be true
          host.networks.each do |net|
            expect(net).to be_instance_of(Pec::Configure::Ethernet)
          end
        end
      end
    end
end
