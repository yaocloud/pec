require 'spec_helper'
require 'ostruct'
describe Pec::Builder::Server do
  before do
    Pec.load_config("spec/fixture/load_config_001.yaml")
    allow_any_instance_of(described_class).to receive(:fetch_image).and_return(OpenStruct.new({id: 1}))
    allow_any_instance_of(described_class).to receive(:fetch_flavor).and_return(OpenStruct.new({id: 1}))
  end
  
  subject {
    described_class.new.build(Pec.configure.first)
  }  

  it 'value_check' do
    expect(subject).to eq(
      {
        name: "pyama-test001.test.com",
        flavor_ref: 1,
        image_ref: 1,
        availability_zone: "nova"
      }
    )
  end
end
