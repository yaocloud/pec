require 'spec_helper'
require 'ostruct'

describe Pec::Handler::Keypair do
  before do
    Pec.load_config("spec/fixture/load_config_001.yaml")

    allow(Yao::Keypair).to receive(:list).and_return(os_keypairs)
  end

  subject {
    described_class.build(Pec.configure.first)
  }

  context "Valid keypair name" do
    let(:os_keypairs) do
      [
        OpenStruct.new({
          id: 1,
          name: "example001"
        })
      ]
    end

    it {
      expect(subject).to eq(
        {key_name: "example001"}
      )
    }
  end
end
