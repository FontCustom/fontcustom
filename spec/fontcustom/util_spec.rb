require "spec_helper"

describe Fontcustom::Util do
  context "#root" do
    it "should return $GEM_ROOT/lib/fontcustom/" do
      version = File.join(Fontcustom::Util.root, "version.rb")
      File.exists?(version).should be_true
    end
  end

  context "#verify_fontforge" do
    it "should raise error if fontforge isn't installed" do
      expect { Fontcustom::Util.verify_fontforge(`which fontforge-does-not-exist`) }.to raise_error(Thor::Error, /install fontforge/)
    end
  end

  context "#verify_input_dir" do
    it "should raise error if input_dir doesn't exist" do
      expect { Fontcustom::Util.verify_input_dir(fixture("does-not-exist")) }.to raise_error(Thor::Error, /isn't a directory/)
    end

    it "should raise error if input_dir doesn't contain vectors" do
      expect { Fontcustom::Util.verify_input_dir(fixture("empty")) }.to raise_error(Thor::Error, /doesn't contain any vectors/)
    end
  end

  context "#verify_output_dir" do
    it "should raise error if output_dir isn't a directory" do 
      output = fixture("not-a-dir")
      expect { Fontcustom::Util.verify_output_dir(output) }.to raise_error(Thor::Error, /isn't a directory/)
    end

    it "should call #reset_output if output_dir exists" do
      output = fixture("mixed-output")
      Fontcustom::Util.stub(:reset_output)
      Fontcustom::Util.should_receive(:reset_output).once.with(/#{output}/)
      Fontcustom::Util.verify_output_dir(output)
    end

    it "should create output_dir if none exists" do
      output = fixture("does-not-exist")
      Fontcustom::Util.stub(:empty_directory)
      Fontcustom::Util.should_receive(:empty_directory).once.with(/#{output}/)
      Fontcustom::Util.verify_output_dir(output)
    end
  end

  context "#reset_output" do
    let(:output) { fixture("mixed-output") }

    it "should create .fontcustom-data if it doesn't exist" do
      Fontcustom::Util.stub(:add_file)
      Fontcustom::Util.should_receive(:add_file).once.with(/.fontcustom-data/)
      Fontcustom::Util.reset_output(fixture("does-not-exist"))
    end

    it "should delete files specified in .fontcustom-data" do
      Fontcustom::Util.stub(:remove_file)
      Fontcustom::Util.stub(:clear_file)
      Fontcustom::Util.should_receive(:remove_file).exactly(5).times
      Fontcustom::Util.reset_output(output)
    end

    it "should not delete non-generated files" do
      Fontcustom::Util.stub(:remove_file)
      Fontcustom::Util.stub(:clear_file)
      Fontcustom::Util.should_not_receive(:remove_file).with(/(dont-delete-me-bro|another-font\.ttf)/)
      Fontcustom::Util.reset_output(output)
    end

    it "should clear the contents of .fontcustom-data" do
      Fontcustom::Util.stub(:remove_file)
      Fontcustom::Util.stub(:clear_file)
      Fontcustom::Util.should_receive(:clear_file).once.with(/\.fontcustom-data/)
      Fontcustom::Util.reset_output(output)
    end
  end
end
