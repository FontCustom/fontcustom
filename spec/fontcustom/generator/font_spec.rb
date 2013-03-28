require "spec_helper"

describe Fontcustom::Generator::Font do
  def generator(options)
    opts = Fontcustom::Util.collect_options options
    Fontcustom::Generator::Font.new([opts])
  end

  def data_file_contents
    {
      :files => [
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.eot", 
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.svg", 
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.ttf", 
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.woff", 
        "fontcustom.css"
      ]
    }
  end

  context "#check_input" do
    it "should raise error if input doesn't exist" do
      options = { :input => fixture("does-not-exist") }
      expect { generator(options).invoke :check_input }.to raise_error Fontcustom::Error, /doesn't exist/
    end

    it "should raise error if input isn't a directory" do
      options = { :input => fixture("not-a-dir") }
      expect { generator(options).invoke :check_input }.to raise_error Fontcustom::Error, /isn't a directory/
    end

    it "should raise error if input doesn't contain vectors" do
      options = { :input => fixture("empty") }
      expect { generator(options).invoke :check_input }.to raise_error Fontcustom::Error, /doesn't contain any vectors/
    end
  end

  context "#check_output" do
    it "should raise an error if output isn't a directory" do
      options = { :output => fixture("not-a-dir") }
      expect { generator(options).check_output }.to raise_error Fontcustom::Error, /isn't a directory/
    end

    it "should create output dir and data file if they don't exist" do
      gen = generator :output => fixture("create-me")
      gen.stub(:add_file)
      gen.should_receive(:add_file).with(fixture("create-me") + "/.fontcustom-data")
      gen.check_output
    end
  end

  context "#get_data" do
    it "should assign empty @data if no data file is found" do
      gen = generator :output => fixture("empty")
      data = gen.get_data
      data.should be_a(Hash)
      data.should be_empty
    end

    it "should assign @data from data file" do
      gen = generator :output => fixture("mixed-output")
      data = gen.get_data
      data.should == data_file_contents
    end
  end

  context "#reset_output" do
    subject do
      gen = generator :output => fixture("mixed-output")
      gen.stub :remove_file
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      gen.instance_variable_set(:@data, data_file_contents)
      gen
    end

    it "should delete files from @data[:files]" do
      subject.should_receive(:remove_file).exactly(5).times
      subject.reset_output
    end

    it "should not delete non-generated files" do
      subject.should_not_receive(:remove_file).with("dont-delete-me.bro")
      subject.should_not_receive(:remove_file).with("another-font.ttf")
      subject.reset_output
    end

    it "should empty @data[:files]" do
      subject.reset_output
      subject.instance_variable_get(:@data)[:files].should be_empty
    end
    
    it "should update the data file" do
      file = File.join(fixture("mixed-output"), ".fontcustom-data")
      Fontcustom::Util.should_receive(:clear_file).once.with(file)
      subject.should_receive(:append_to_file).once.with(file, /:files: \[\]/)
      subject.reset_output
    end
  end

  context "#generate" do
    it "should call fontforge"
    it "should options to fontforge"
    it "should raise error if fontforge fails"
  end

  context "#collect_data" do
    it "should assign @data from updated data file (TODO implement this in generate.py"
    it "should parse output for file names (TEMP)"
    it "should parse input for icon names (TEMP)"
    it "should assign @data[:files] and @data[:icons] and update data file (TEMP)" 
  end

  context "#announce_files" do
    it "should print generated files to console"
  end
end
