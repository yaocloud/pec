require 'spec_helper'
require 'base64'
describe Pec::Configure do
  describe 'standard' do
    before do
      @configure = Pec::Configure.new("spec/fixture/in/pec_configure_p1.yaml")
    end

    it 'host' do
      host = @configure.first
      expect(host.flavor).to eq("m1.small")
      expect(host.image).to eq("centos-7.1_chef-12.3_puppet-3.7")
      expect(host.name).to eq("pyama-test001")
    end

    it 'ether' do
      net = @configure.first.networks.first
      expect(net.bootproto).to eq("static")
      expect(net.ip_address).to eq("10.10.10.10/24")
      expect(net.name).to eq("eth0")
      expect(net.options).to eq({"gateway" => "10.10.10.254"})
    end

    it "security_group" do
      expect(@configure.first.security_group).to eq(["default", "office"])
    end

    it "user_data" do
      host = @configure.first
      allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_configure_p1.yaml"))
      allow(FileTest).to receive(:exist?).and_return(true)
      expect(Pec::Configure::UserData.make(host, nil)).to eq(
        Base64.encode64("#cloud-config\n" + host.user_data.merge(YAML.load_file("spec/fixture/stub/pec_configure_p1.yaml").to_hash).to_yaml)
      )
    end
  end

  describe 'validate' do
    describe 'host' do
      describe 'must column' do
        shared_examples_for 'require test' do
          it do
            hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
            hash["pyama-test001"].delete(column)
            expect { Pec::Configure.new(hash)}.to raise_error(Pec::Errors::Host)
          end
        end

        shared_examples_for 'null test' do
          it do
            hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
            hash["pyama-test001"][column] = nil
            expect { Pec::Configure.new(hash)}.to raise_error(Pec::Errors::Host)
          end
        end
        describe 'image' do
          let(:column) { "image" }
          it_behaves_like 'require test'
          it_behaves_like 'null test'
        end
        describe 'flavor' do
          let(:column) { "flavor" }
          it_behaves_like 'require test'
          it_behaves_like 'null test'
        end
        describe 'tenant' do
          let(:column) { "tenant" }
          it_behaves_like 'require test'
          it_behaves_like 'null test'
        end
      end
    end
    describe 'network' do
      describe 'require' do
        describe 'bootproto' do
          before do
            @hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
            @hash["pyama-test001"]["networks"]["eth0"].delete("bootproto")
          end
          it { expect { Pec::Configure.new(@hash)}.to raise_error(Pec::Errors::Ethernet) }
        end
        describe 'ip address by bootproto is static' do
          before do
            @hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
            @hash["pyama-test001"]["networks"]["eth0"]["bootproto"] = "static"
            @hash["pyama-test001"]["networks"]["eth0"].delete("ip_address")
          end
          it { expect { Pec::Configure.new(@hash)}.to raise_error(Pec::Errors::Ethernet) }
        end
      end
      describe 'unknown bootproto' do
        describe 'not static and dhcp' do
          before do
            @hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
            @hash["pyama-test001"]["networks"]["eth0"]["bootproto"] = "hoge"
          end
          it { expect { Pec::Configure.new(@hash)}.to raise_error(Pec::Errors::Ethernet) }
        end
      end
    end
  end
end
