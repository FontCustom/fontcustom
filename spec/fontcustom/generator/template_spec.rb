require "spec_helper"

describe Fontcustom::Generator::Template do
  def generator(options)
    opts = Fontcustom::Util.collect_options options
    Fontcustom::Generator::Template.new([opts])
  end

  context "#load_data" do
    it "should raise error if data file doesn't exist" do 
      gen = generator :output => fixture("empty")
      expect { gen.load_data }.to raise_error Fontcustom::Error, /couldn't find a \.fontcustom-data/
    end

    it "should assign @data from data file" do
      gen = generator :output => fixture("mixed-output")
      gen.load_data
      gen.instance_variable_get(:@data).should == data_file_contents
    end
  end

  context "#copy_templates" do
    subject do
      gen = generator :output => fixture("mixed-output"), :templates => %W|scss css #{fixture("not-a-dir")}|
      gen.instance_variable_set :@data, data_file_contents
      gen.stub :template
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      gen
    end

    it "should raise an error if no templates are given" do 
      gen = generator :templates => []
      expect { gen.copy_templates }.to raise_error Fontcustom::Error, /No templates were specified/
    end

    it "should call #template for each template" do
      subject.should_receive(:template).exactly(3).times
      subject.copy_templates
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
      subject.copy_templates
    end
  end
end
