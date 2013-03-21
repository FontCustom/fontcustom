require "spec_helper"

describe Fontcustom::Util do
  context "#root" do
    it "should return $GEM_ROOT/lib/fontcustom/" do
      version = File.join(Fontcustom::Util.root, "version.rb")
      File.exists?(version).should be_true
    end
  end

  context "#verify_*" do
    it "should raise error if fontforge isn't installed" do
      expect { Fontcustom::Util.verify_fontforge(`which fontforge-does-not-exist`) }.to raise_error(Thor::Error, /install fontforge/)
    end

    it "should raise error if input_dir doesn't exist" do
      expect { Fontcustom::Util.verify_input_dir(fixture("does-not-exist")) }.to raise_error(Thor::Error, /isn't a directory/)
    end

    it "should raise error if input_dir doesn't contain vectors" do
      expect { Fontcustom::Util.verify_input_dir(fixture("empty")) }.to raise_error(Thor::Error, /doesn't contain any vectors/)
    end
  end

  context "#reset_data" do
    it "should create .fontcustom-data if it doesn't exist" do
      Fontcustom::Util.stub(:add_file)
      Fontcustom::Util.should_receive(:add_file).once.with(/.fontcustom-data/)

      options = Fontcustom::Options.new
      Fontcustom::Util.reset_data(options)
    end

    it "should delete files specified in .fontcustom-data" do
      Fontcustom::Util.stub(:remove_file)
      Fontcustom::Util.should_receive(:remove_file).exactly(5).times

      options = Fontcustom::Options.new(:output_dir => fixture("mixed-output"))
      Fontcustom::Util.reset_data(options)
    end

    it "should not delete non-generated files" do
      Fontcustom::Util.stub(:remove_file)
      Fontcustom::Util.should_not_receive(:remove_file).with(/(dont-delete-me-bro|another-font\.ttf)/)

      options = Fontcustom::Options.new(:output_dir => fixture("mixed-output"))
      Fontcustom::Util.reset_data(options)
    end

    it "should clear the contents of .fontcustom-data (ALT - this could be implemented in individual generators)"
  end
end
