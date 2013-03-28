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
      data[:files] =~ data_file_contents[:files]
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
    subject do
      gen = generator(:input => fixture("vectors"), :output => fixture("generate-spec"))
      gen.stub(:"`").and_return ""
      gen
    end
    
    it "should call fontforge" do
      subject.should_receive(:"`").with(/fontforge -script/)
      subject.generate
    end

    it "should options to fontforge" do
      subject.should_receive(:"`").with(/#{fixture("vectors")}.+#{fixture("generate-spec")}/)
      subject.generate
    end

    it "should raise error if fontforge fails" do
      pending "What does a fontforge failure look like?"
    end
  end

  context "#collect_data" do
    subject do
      gen = generator(:input => fixture("vectors"), :output => fixture("mixed-output"))
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      gen.instance_variable_set(:@data, {:files => []})
      gen
    end

    it "should assign @data from updated data file (TODO)"

    it "should assign @data from input and output files (TEMP)" do
      subject.collect_data
      data = subject.instance_variable_get(:@data)
      data[:icons].should =~ ["c", "d", "a_r3ally-exotic-f1le-name"]
      data[:file_name].should == "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e" 
      data[:files].should =~ [
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.eot", 
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.svg", 
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.ttf", 
        "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.woff"
      ]
    end

    it "should update data file (TEMP)" do
      file = File.join(fixture("mixed-output"), ".fontcustom-data")
      Fontcustom::Util.should_receive(:clear_file).once.with(file)
      subject.should_receive(:append_to_file).once.with do |path, content|
        path.should == file
        content.should match(/:files:/)
        content.should match(/:icons:/)
        content.should match(/:file_name:/)
      end
      subject.collect_data
    end
  end

  context "#announce_files" do
    it "should print generated files to console" do
      gen = generator(:input => fixture("vectors"), :output => fixture("mixed-output"))
      gen.instance_variable_set :@data, data_file_contents 
      stdout = capture(:stdout) { gen.announce_files }
      stdout.should =~ /create.+\.(woff|ttf|eot|svg)/
    end
  end
end
