require "spec_helper"

describe Fontcustom::Base do
  context "#compile" do
    #context "when checksum != manifest[:checksum]" do
      #it "should call .start_generators"
      #it "should set manifest[:checksum]"
    #end

    context "when checksum equals manifest[:checksum]" do
      it "should show 'no change' message" do
        Fontcustom::Base.any_instance.stub :init_manifest
        Fontcustom::Base.any_instance.stub :check_fontforge
        base = Fontcustom::Base.new({})
        base.stub(:checksum).and_return("abc")
        base.instance_variable_set :@manifest, {:checksum => "abc"}
        base.instance_variable_set :@options, {:quiet => false}

        output = capture(:stdout) { base.compile }
        output.should match(/No changes/)
      end
    end
  end

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
      manifest = double("manifest")
      manifest.should_receive(:manifest).and_return(manifest_contents)
      Fontcustom::Manifest.stub(:new).and_return manifest
    end

    it "should pass CLI options to FC::Options" do
      opts = double "options"
      opts.should_receive :options
      Fontcustom::Options.should_receive(:new).with({:foo => "bar"}).and_return opts
      Fontcustom::Base.new :foo => "bar"
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
