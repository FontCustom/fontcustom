require "spec_helper"

describe Fontcustom::Utility do
  class Generator
    include Fontcustom::Utility
    attr_accessor :options, :manifest

    def initialize
      @options = { :quiet => false }
      @manifest = fixture ".fontcustom-manifest.json"
    end
  end

  it "should include Thor::Action methods" do
    gen = Generator.new
    %w|template add_file remove_file|.each do |method|
      gen.should respond_to(method.to_sym)
    end
  end

  context "#symbolize_hash" do
    it "should turn string keys into symbols" do
      gen = Generator.new
      hash = gen.symbolize_hash "foo" => "bar"
      hash.should == { :foo => "bar" }
    end
  end

  context "#methodize_hash" do
    it "should define getter method" do
      gen = Generator.new
      hash = gen.methodize_hash :foo => "bar"
      hash.foo.should == "bar"
    end

    it "should define setter method" do
      gen = Generator.new
      hash = gen.methodize_hash :foo => "bar"
      hash.foo = "baz"
      hash.foo.should == "baz"
    end
  end

  context "#write_file" do
    it "should replace the contents of a file" do
      gen = Generator.new
      file = double "file"
      File.should_receive(:open).with(fixture("shared/test"), "w").and_yield file
      file.should_receive(:write).with("testing")
      gen.write_file fixture("shared/test"), "testing"
    end
  end

  #context "#say_message" do
    #it "should not respond if :quiet is true" do
      #pending
      #gen = Generator.new
      #gen.options[:quiet] = true
      #output = capture(:stdout) { gen.say_message(:test, "Hello") }
      #output.should == ""
    #end
  #end

  #context "#say_changed" do
    #it "should strip :project_root from changed paths" do
      #pending
      #changed = %w|a b c|.map { |file| fixture(file) }
      #gen = Generator.new
      #output = capture(:stdout) { gen.say_changed(:success, changed) }
      #output.should_not match(fixture)
    #end

    #it "should not respond if :quiet is true " do
      #pending
      #changed = %w|a b c|.map { |file| fixture(file) }
      #gen = Generator.new
      #gen.options[:quiet] = true
      #output = capture(:stdout) { gen.say_changed(:success, changed) }
      #output.should == ""
    #end
  #end
end
