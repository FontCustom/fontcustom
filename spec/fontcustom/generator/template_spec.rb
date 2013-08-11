require "spec_helper"

describe Fontcustom::Generator::Template do
  def generator(options)
    opts = Fontcustom::Util.collect_options options
    Fontcustom::Generator::Template.new([opts])
  end

  context "#get_data" do
    it "should raise error if data file doesn't exist" do 
      gen = generator(
        :project_root => fixture,
        :input => "vectors",
        :output => "empty"
      )
      expect { gen.get_data }.to raise_error Fontcustom::Error, /no \.fontcustom-data/
    end

    # TODO ensure data file is correct
    it "should assign @data from data file" do
      gen = generator(
        :project_root => fixture,
        :input => "vectors",
        :output => "mixed-output"
      )
      gen.get_data
      gen.instance_variable_get(:@data)[:templates].should =~ data_file_contents[:templates]
    end
  end

  context "#check_templates" do
    it "should raise an error if no templates are given" do 
      gen = generator :templates => []
      expect { gen.check_templates }.to raise_error Fontcustom::Error, /No templates were specified/
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

    it "should delete files from @data[:templates]" do
      subject.should_receive(:remove_file).once.with(/fontcustom\.css/, :verbose => true)
      subject.reset_output
    end

    it "should not delete non-template files" do
      subject.should_not_receive(:remove_file).with("dont-delete-me.bro")
      subject.should_not_receive(:remove_file).with("another-font.ttf")
      subject.should_not_receive(:remove_file).with(/fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e/)
      subject.reset_output
    end

    it "should empty @data[:fonts]" do
      subject.reset_output
      subject.instance_variable_get(:@data)[:templates].should be_empty
    end
    
    it "should update the data file" do
      file = File.join(fixture("mixed-output"), ".fontcustom-data")
      Fontcustom::Util.should_receive(:clear_file).once.with(file)
      subject.should_receive(:append_to_file).once.with(file, /"templates":/, :verbose => false)
      subject.reset_output
    end

    it "should be silent" do
      stdout = capture(:stdout) { subject.reset_output }
      stdout.should == ""
    end
  end

  context "#generate" do
    subject do
      gen = generator :output => fixture("mixed-output"), :templates => %W|scss css #{fixture("not-a-dir")}|
      gen.instance_variable_set :@data, data_file_contents
      gen.stub :template
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      gen
    end

    it "should call #template for each template" do
      subject.should_receive(:template).exactly(3).times
      subject.generate
    end

    it "should update data file" do 
      file = File.join fixture("mixed-output"), ".fontcustom-data"
      Fontcustom::Util.should_receive(:clear_file).once.with(file)
      subject.should_receive(:append_to_file).once.with do |path, content|
        path.should == file
        content.should match(/fontcustom\.css/)
        content.should match(/_fontcustom\.scss/)
        content.should match(/not-a-dir/)
      end
      subject.generate
    end

    it "should be silent if verbose is false" do
      gen = generator :output => fixture("mixed-output"), :templates => %W|scss css #{fixture("not-a-dir")}|, :verbose => false
      gen.instance_variable_set :@data, data_file_contents
      gen.stub :template
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      stdout = capture(:stdout) { gen.generate }
      stdout.should == ""
    end
  end
end
