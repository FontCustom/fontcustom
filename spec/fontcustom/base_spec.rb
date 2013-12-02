require "spec_helper"

describe Fontcustom::Base do
  before(:each) { Fontcustom::Manifest.any_instance.stub(:write_file) }

  context "#compile" do
    context "when [:checksum][:current] equals [:checksum][:previous]" do
      it "should show 'no change' message" do
        Fontcustom::Base.any_instance.stub :check_fontforge
        options = double("options")
        options.stub(:options).and_return({})
        Fontcustom::Options.stub(:new).and_return options

        output = capture(:stdout) do
          base = Fontcustom::Base.new({})
          manifest = base.instance_variable_get :@manifest
          manifest.stub(:get).and_return :previous => "abc"
          base.stub(:checksum).and_return "abc"
          base.compile
        end
        output.should match(/No changes/)
      end
    end
  end

  context ".check_fontforge" do
    it "should raise error if fontforge isn't installed" do
      Fontcustom::Base.any_instance.stub(:"`").and_return("")
      expect { Fontcustom::Base.new(:option => "foo") }.to raise_error Fontcustom::Error, /fontforge/
    end
  end

  context ".checksum" do
    it "should return hash of all vectors and templates" do
      pending "SHA2 is different on CI servers. Why?"
      Fontcustom::Base.any_instance.stub :check_fontforge
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
