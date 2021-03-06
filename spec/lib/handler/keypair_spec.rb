require 'spec_helper'
require 'ostruct'

describe Pec::Handler::Keypair do
  before do
    Pec.load_config("spec/fixture/basic_config.yaml")

    allow(Yao::Keypair).to receive(:list).and_return(os_keypairs)
  end

  subject {
    described_class.build(Pec.configure.first)
  }

  context "Valid keypair name" do
    let(:os_keypairs) do
      [
        double(
          id: 1,
          name: "example001"
        )
      ]
    end

    it {
      expect(subject).to eq(
        {key_name: "example001"}
      )
    }
  end

  context "invalid keypair name" do
    let(:os_keypairs) do
      [
        double(
          id: 1,
          name: "invalid-example001"
        )
      ]
    end

    it {
      expect{ subject }.to raise_error(Pec::ConfigError)
    }
  end

  context "no keypair" do
    let(:os_keypairs) do
      [
        double(
          id: 1,
          name: "example001"
        )
      ]
    end

    it {
      allow(Pec.configure).to receive(:first).and_return(double(keypair: nil))
      expect(subject).to eq({})
    }
  end
end
