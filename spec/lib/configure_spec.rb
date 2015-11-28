require 'spec_helper'
describe Pec do
  before do
    Pec.config_reset
  end

  shared_examples_for 'value_check' do
    before do
      Pec.load_config(file_name)
    end

    it do
      expect(Pec.configure.first.name).to eq("pyama-test001.test.com")
      expect(Pec.configure.first.tenant).to eq("test_tenant")
      expect(Pec.configure.first.availability_zone).to eq("nova")
      expect(Pec.configure.last.name).to eq("pyama-test002.test.com")
      expect(Pec.configure.last.tenant).to eq("include_test_tenant")
    end
  end
  context 'yaml' do
    let(:file_name) {"spec/fixture/basic_config.yaml"}
    it_behaves_like 'value_check'
  end

  context 'erb' do
    let(:file_name) {"spec/fixture/erb_basic_config.yaml.erb"}
    it_behaves_like 'value_check'
  end
end
