require 'spec_helper'
describe Pec::Handler::Templates do
  before do
    Pec.config_reset
    allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
    allow(FileTest).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/user_data_template.yaml"))
  end

  subject {
    described_class.build(Pec.configure.first)
  }

  it 'value_check' do
    expect(subject).to eq(
      {
        :user_data =>
        {
          "users"=> [
            {
              "name" => 2
            }
          ]
        }
      }
    )
  end
end
