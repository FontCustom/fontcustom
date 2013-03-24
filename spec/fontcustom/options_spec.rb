require "spec_helper"

describe Fontcustom::Options do
  context "#initialize" do
    it "should save all options as attributes" do
      # TODO flesh this out?
      attrs = [:font_name, :font_path, :input_dir, :output_dir, :templates, :css_prefix, :hash, :html, :debug]
      attrs.each {|attr| subject.should respond_to(attr) }
    end

    it "should work without config file or CL args" do
      subject.font_name.should eq("fontcustom")
    end

    it "should overwrite defaults from a config file" do
      with_config = Fontcustom::Options.new(:config_file => fixture("fontcustom.yml"))
      with_config.font_name.should eq("custom-name-from-config")
    end

    it "should overwrite defaults and config with CL args" do
      with_config_and_args = Fontcustom::Options.new(:font_name => "custom-name-from-args", :config_file => fixture("fontcustom.yml"))
      with_config_and_args.font_name.should eq("custom-name-from-args")
    end

    it "should normalize font names to lower-spinal-case" do
      with_weird_name = Fontcustom::Options.new(:font_name => "a ContRiveD_eXample")
      with_weird_name.font_name.should eq("a-contrived_example")
    end
  end
end
