require "spec_helper"

describe Fontcustom::Generator::Template do
  context "#initialize" do
    it "should raise error if not passed options" do
      expect { Fontcustom::Generator::Template.new }.to raise_error(ArgumentError)
    end
  end

  context "#start" do
    it "should raise error if no templates are specified" do
      options = Fontcustom::Options.new :templates => []
      generator = Fontcustom::Generator::Template.new options
      expect { generator.start }.to raise_error Thor::Error, /No templates/
    end
  end

  context ".template_paths" do
    it "should convert symbols to correct paths" do 
      # TODO update this once additional templates are added
      templates = [:scss, :html]
      options = Fontcustom::Options.new :templates => templates
      generator = Fontcustom::Generator::Template.new options
      paths = generator.send :template_paths
      paths[0].should =~ /_fontcustom\.scss/
      paths[1].should =~ /fontcustom\.html/
    end
  end

  context ".generate" do
    it "should run Fontcustom.templates for each template" do
      templates = [:scss, :html]
      options = Fontcustom::Options.new :templates => templates
      generator = Fontcustom::Generator::Template.new options
      paths = generator.send :template_paths
      Fontcustom.stub :templates
      Fontcustom.should_receive(:generate).twice
      generator.send :generate, paths
    end

    it "should update .fontcustom-data with any files created"
  end
end
