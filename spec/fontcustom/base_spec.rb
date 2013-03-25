require "spec_helper"

describe Fontcustom::Base do
  context ".gem_lib" do
    it "should return $GEM_ROOT/lib/fontcustom/" do
      version = File.join(Fontcustom::Base.gem_lib, "version.rb")
      File.exists?(version).should be_true
    end
  end

  context "#load" do
    it "should initialize options" do
      subject.load :input_dir => fixture("vectors"), :output_dir => fixture("new-test")
      subject.opts.should be_a(Fontcustom::Options)
    end

    it "should add source_paths" do 
      subject.load :input_dir => fixture("vectors"), :output_dir => fixture("new-test")
      subject.source_paths.length.should == 3
    end
  end

  context "#verify_fontforge" do
    it "should raise error if fontforge isn't installed" do
      expect { subject.verify_fontforge(`which fontforgggggge`) }.to raise_error(Thor::Error, /install fontforge/)
    end
  end

  context "#verify_input_dir" do
    it "should raise error if input_dir doesn't exist" do
      subject.load :input_dir => fixture("does-not-exist")
      expect { subject.verify_input_dir }.to raise_error(Thor::Error, /doesn't exist/)
    end

    it "should raise error if input_dir doesn't contain vectors" do
      subject.load :input_dir => fixture("empty")
      expect { subject.verify_input_dir }.to raise_error(Thor::Error, /doesn't contain any vectors/)
    end
  end

  context "#verify_output_dir" do
    it "should raise error if output_dir isn't a directory" do 
      subject.load :output_dir => fixture("not-a-dir")
      expect { subject.verify_output_dir }.to raise_error(Thor::Error, /isn't a directory/)
    end

    it "should call #reset_output_dir if output_dir exists" do
      subject.load :output_dir => fixture("mixed-output")
      subject.stub :reset_output_dir
      subject.should_receive(:reset_output_dir).once
      subject.verify_output_dir
    end
  end

  context "#reset_output_dir" do
    let(:output) { fixture("mixed-output") }

    it "should create .fontcustom-data if it doesn't exist" do
      subject.load :output_dir => fixture("empty")
      subject.stub(:add_file)
      subject.should_receive(:add_file).once.with(/\.fontcustom-data/)
      subject.reset_output_dir
    end

    it "should delete files specified in .fontcustom-data" do
      subject.load :output_dir => output
      subject.stub(:remove_file)
      subject.stub(:clear_data_file)
      subject.should_receive(:remove_file).exactly(5).times
      subject.reset_output_dir
    end

    it "should not delete non-generated files" do
      subject.load :output_dir => output
      subject.stub(:remove_file)
      subject.stub(:clear_data_file)
      subject.should_not_receive(:remove_file).with(/(dont-delete-me-bro|another-font\.ttf)/)
      subject.reset_output_dir
    end

    it "should clear the contents of .fontcustom-data" do
      subject.load :output_dir => output
      subject.stub(:remove_file)
      subject.stub(:clear_data_file)
      subject.should_receive(:clear_data_file).once
      subject.reset_output_dir
    end
  end
end
