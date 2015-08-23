require 'spec_helper'
describe Pec::Builder::UserData do
  before do
    Pec.load_config("spec/fixture/load_config_001.yaml")
    allow(FileTest).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/user_data_template.yaml"))
  end

  subject {
    described_class.new.build(Pec.configure.first, nil)
  }  
  
  it 'value_check' do
    expect(subject).to eq(
      {
        user_data: "#cloud-config\n---\nhostname: pyama-test001\nusers:\n- name: 1\n- name: 2\nfqdn: pyama-test001.test.com\n"
      }
    )
  end
end
