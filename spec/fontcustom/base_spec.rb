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

  context ".init_manifest" do
    before(:each) do
      Fontcustom::Base.any_instance.stub :check_fontforge
      Fontcustom::Generator::Manifest.stub :new
    end

    it "should pass CLI options to FC::Options" do
      opts = double "options"
      opts.should_receive :options
      Fontcustom::Options.should_receive(:new).with({:foo => "bar"}, {}).and_return opts
      Fontcustom::Base.new :foo => "bar"
    end

    it "should pass previous manifest's options to FC::Options" do
      opts = double "options"
      opts.should_receive :options
      options = {:manifest => fixture("generators/.fontcustom-manifest.json")}
      previous_options = {:foo => "bar", :baz => "bum"}
      Fontcustom::Options.should_receive(:new).with(options, previous_options).and_return opts
      Fontcustom::Base.new options 
    end
  end

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
