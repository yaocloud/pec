require 'spec_helper'
require 'base64'
describe Pec::Director do
  before do
    allow(FileTest).to receive(:exist?).and_return(true)
    Pec::Resource.set_tenant("1")
  end
  describe 'director' do
    before do
      allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_director_p1.yaml"))
    end
    it 'OK' do
      expect{ Pec::Director.execute("make", 1) }.to_not raise_error
    end
  end

  describe 'make director' do
    describe 'OK' do
      before do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_director_p1.yaml"))
        @configure = Pec::Configure.new("spec/fixture/stub/pec_director_p1.yaml")
        @director  =  Pec::Director::MakeDirector.new
      end
      it { expect( @director.execute!(@configure.first) ).to eq 1 }
    end
    describe 'NG' do
      before do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_director_p2.yaml"))
        @configure = Pec::Configure.new("spec/fixture/stub/pec_director_p2.yaml")
        @director  =  Pec::Director::MakeDirector.new
      end
      it {  expect{ @director.execute!(@configure.first) }.to raise_error(Pec::Errors::Port) }
    end
  end

  describe 'destroy director' do
    describe 'OK' do
      before do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_director_p3.yaml"))
        @configure = Pec::Configure.new("spec/fixture/stub/pec_director_p3.yaml")
        @director  =  Pec::Director::DestroyDirector.new({:force => true})
      end
      it { expect( @director.execute!(@configure.first) ).to be true }
    end
    describe 'NG' do
      before do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_director_p1.yaml"))
        @configure = Pec::Configure.new("spec/fixture/stub/pec_director_p1.yaml")
        @director  =  Pec::Director::DestroyDirector.new({:force => true})
      end
      it {  expect{ @director.execute!(@configure.first) }.to raise_error(Pec::Errors::Host) }
    end
  end
end
