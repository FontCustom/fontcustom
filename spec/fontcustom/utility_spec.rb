require 'spec_helper'

describe Fontcustom::Utility do
  class Generator
    include Fontcustom::Utility
    attr_accessor :options

    def initialize
      @options = { :project_root => fixture, :quiet => false }
    end
  end

  context "#symbolize_hash" do
    it "should turn string keys into symbols"
  end

  context "#methodize_hash" do
    it "should allow method access to hash keys"
  end

  context "#expand_path" do
    it "should leave absolute paths alone" do
      gen = Generator.new
      path = gen.expand_path "/absolute/path"
      path.should == "/absolute/path"
    end

    it "should prepend paths with :project_root" do
      gen = Generator.new
      path = gen.expand_path "generators"
      path.should == fixture("generators")
    end

    it "should follow ../../ relative paths" do
      gen = Generator.new
      gen.options[:project_root] = fixture("shared/vectors")
      path = gen.expand_path "../../generators"
      path.should == fixture("generators")
    end
  end

  context "#overwrite_file" do
    it "should replace the contents of a file"
  end

  context "#get_manifest" do
    it "should parse the manifest file"
    it "should raise an error if the file is missing"
    it "should raise an error if the file is corrupted"
  end

  context "#set_manifest" do
    it "should update the manifest"
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

  context "#say_message" do 
    it "should not respond if :quiet is true" do
      pending
      gen = Generator.new
      gen.options[:quiet] = true
      output = capture(:stdout) { gen.say_message(:test, "Hello") }
      output.should == ""
    end
  end

  context "#say_changed" do
    it "should strip :project_root from changed paths" do
      pending
      changed = %w|a b c|.map { |file| fixture(file) }
      gen = Generator.new
      output = capture(:stdout) { gen.say_changed(:success, changed) }
      output.should_not match(fixture)
    end

    it "should not respond if :quiet is true " do
      pending
      changed = %w|a b c|.map { |file| fixture(file) }
      gen = Generator.new
      gen.options[:quiet] = true
      output = capture(:stdout) { gen.say_changed(:success, changed) }
      output.should == ""
    end
  end
end
