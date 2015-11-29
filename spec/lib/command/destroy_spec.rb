require 'spec_helper'
describe Pec::Command::Destroy do
  before do
    Pec.config_reset

    allow(Pec).to receive(:init_yao).and_return(true)

    allow(Yao::Tenant).to receive(:list).and_return([
      double(id: 1, name: "test_tenant"),
      double(id: 2, name: "include_test_tenant"),
    ])

    allow(Yao::Server).to receive(:list_detail).and_return(servers)
  end

  context 'destroy_insance' do
    subject { described_class.run([]) }
    let(:servers) {
      [
        double(id: 1, name: "pyama-test001.test.com", status: "ACTIVE"),
        double(id: 2, name: "pyama-test002.test.com", status: "ACTIVE")
      ]
    }

    before do
      allow(Yao::Server).to receive(:destroy)
    end

    context 'filter' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
        allow(Thor::LineEditor).to receive(:readline).and_return("y")
      end

      context 'any' do
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).to have_received(:destroy).with(1)
          expect(Yao::Server).to have_received(:destroy).with(2)
        end
      end

      context 'unmatch' do
        subject { described_class.run(["unmatch"]) }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:destroy)
        end
      end

      context 'single' do
        subject { described_class.run([".*test002"]) }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:destroy).with(1)
          expect(Yao::Server).to have_received(:destroy).with(2).once
        end
      end
    end

    context 'force' do
      subject { Pec::CLI.new.invoke(:destroy, [], {force: force}) }

      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
      end

      context 'true' do
        let(:force) { true }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).to have_received(:destroy).with(1)
          expect(Yao::Server).to have_received(:destroy).with(2)
        end
      end

      context 'false' do
        let(:force) { false}
        before do
          allow(Thor::LineEditor).to receive(:readline).and_return("n")
        end

        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:destroy).with(1)
          expect(Yao::Server).not_to have_received(:destroy).with(2)
        end
      end
    end
  end
end
