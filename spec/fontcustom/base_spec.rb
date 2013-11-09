require "spec_helper"

describe Fontcustom::Base do
  #context "#compile" do
    #context "when checksum != manifest[:checksum]" do
      #it "should call .start_generators"
      #it "should set manifest[:checksum]"
    #end

    #context "when checksum == manifest[:checksum]" do
      #it "should show 'no change' message"
    #end
  #end

  context ".check_fontforge" do
    it "should raise error if fontforge isn't installed" do
      Fontcustom::Base.any_instance.stub :init_manifest
      Fontcustom::Base.any_instance.stub(:"`").and_return("")
      expect { Fontcustom::Base.new(:option => "foo") }.to raise_error Fontcustom::Error, /fontforge/
    end
  end

  #context ".init_manifest" do
    #it "should pass CLI options to FC::Options"
    #it "should assign @manifest from options"
    #it "should init a FC::Gen::Manifest with options"
  #end

  context ".checksum" do
    it "should return hash of all vectors and templates" do
      pending "SHA2 is different on CI servers. Why?"
      Fontcustom::Base.any_instance.stub :check_fontforge
      Fontcustom::Base.any_instance.stub :init_manifest
      base = Fontcustom::Base.new({})
      base.instance_variable_set :@options, {
        :input => {:vectors => fixture("shared/vectors")}, 
        :templates => Dir.glob(File.join(fixture("shared/templates"), "*"))
      }
      hash = base.send :checksum
      hash.should == "81ffd2f72877be02aad673fdf59c6f9dbfee4cc37ad0b121b9486bc2923b4b36"
    end
  end
end
