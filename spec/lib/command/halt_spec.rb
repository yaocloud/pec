require 'spec_helper'
describe Pec::Command::Halt do
  before do
    Pec.config_reset

    allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
    allow(Pec).to receive(:init_yao).and_return(true)
    allow(Yao::Tenant).to receive(:list).and_return([
      double(id: 1, name: "test_tenant"),
      double(id: 2, name: "include_test_tenant"),
    ])
    allow(Yao::Server).to receive(:list_detail).and_return(servers)
      allow(Yao::Server).to receive(:shutoff)
  end

  context 'shutoff_insance' do
    subject { described_class.run([]) }

    context 'status' do
      let(:servers) {
        [
          double(id: 1, name: "pyama-test001.test.com", status: "SHUTOFF"),
          double(id: 2, name: "pyama-test002.test.com", status: "SHUTOFF")
        ]
      }

      context 'shutoff' do
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:shutoff)
        end
      end
    end

    context 'filter' do
      let(:servers) {
        [
          double(id: 1, name: "pyama-test001.test.com", status: "ACTIVE"),
          double(id: 2, name: "pyama-test002.test.com", status: "ACTIVE")
        ]
      }

      context 'any' do
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).to have_received(:shutoff).with(1)
          expect(Yao::Server).to have_received(:shutoff).with(2)
        end
      end

      context 'unmatch' do
        subject { described_class.run(["unmatch"]) }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:shutoff)
        end
      end

      context 'single' do
        subject { described_class.run([".*test002"]) }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:shutoff).with(1)
          expect(Yao::Server).to have_received(:shutoff).with(2).once
        end
      end
    end
  end
end
