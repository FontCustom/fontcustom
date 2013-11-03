require 'spec_helper'

describe Fontcustom::Base do

  # Pending specs are for documentation purposes only
  context "#initialize" do
    it "should pass CLI options to FC::Options"
    it "should assign @manifest from options"
    it "should init a FC::Gen::Manifest with options"
  end

  context "#compile" do
    context "when checksum[:current] != checksum[:previous]" do
      it "should call .start_generators"
      it "should set checksum[:previous] to checksum[:current]"
    end

    context "when checksum[:current] == checksum[:previous]" do
      it "should show 'no change' message"
    end
  end

  context ".checksum" do
    it "should return hash of all vectors and templates" do
      options = {
        :input => {:vectors => fixture("shared/vectors")}, 
        :templates => Dir.glob(File.join(fixture("shared/templates"), "*"))
      }
      Fontcustom::Options.stub(:new).and_return options
      Fontcustom::Generator::Manifest.stub :new

      base = Fontcustom::Base.new(:options => "foo")
      hash = base.send :checksum
      hash.should == "81ffd2f72877be02aad673fdf59c6f9dbfee4cc37ad0b121b9486bc2923b4b36"
    end
  end
end
