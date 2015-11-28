require 'spec_helper'
describe Pec do
  before do
    Pec.config_reset
  end

  context 'yaml' do
    before do
      Pec.load_config("spec/fixture/basic_config.yaml")
    end

    it 'value_check' do
      expect(Pec.configure.first.name).to eq("pyama-test001.test.com")
      expect(Pec.configure.first.tenant).to eq("test_tenant")
      expect(Pec.configure.first.availability_zone).to eq("nova")
      expect(Pec.configure.last.name).to eq("pyama-test002.test.com")
      expect(Pec.configure.last.tenant).to eq("include_test_tenant")
    end
  end

  context 'erb' do

  end
end
