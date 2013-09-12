require 'spec_helper'

describe Fontcustom::Util do
  class Generator
    include Fontcustom::Util
    attr_accessor :cli_options

    def initialize
      @cli_options = { :project_root => fixture, :verbose => true }
      @shell = Thor::Shell::Color.new
    end
  end

  context "#check_fontforge" do
    it "should raise error if fontforge isn't installed" do
      gen = Generator.new
      gen.stub(:"`").and_return("")
      expect { gen.check_fontforge }.to raise_error Fontcustom::Error, /install fontforge/
    end
  end

  context "#say_changed" do
    it "should strip :project_root from changed paths" do
      changed = %w|a b c|.map { |file| fixture(file) }
      gen = Generator.new
      output = capture(:stdout) { gen.say_changed(:success, changed) }
      output.should_not match(fixture)
    end

    it "should not respond if :verbose is false" do
      changed = %w|a b c|.map { |file| fixture(file) }
      gen = Generator.new
      gen.cli_options[:verbose] = false
      output = capture(:stdout) { gen.say_changed(:success, changed) }
      output.should == ""
    end
  end

  context "#say_message" do 
    it "should not respond if :verbose is false" do
      gen = Generator.new
      gen.cli_options[:verbose] = false
      output = capture(:stdout) { gen.say_message(:test, "Hello") }
      output.should == ""
    end
  end

  context "#relative_to_root" do
    it "should trim project root from paths" do
      gen = Generator.new
      path = gen.relative_to_root fixture("test/path")
      path.should == "test/path"
    end

    it "should trim beginning slash" do
      gen = Generator.new
      path = gen.relative_to_root "/test/path"
      path.should == "test/path"
    end
  end
end
