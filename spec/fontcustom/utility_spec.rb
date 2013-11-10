require "spec_helper"

describe Fontcustom::Utility do
  class Generator
    include Fontcustom::Utility
    attr_accessor :options

    def initialize
      @options = { :project_root => fixture, :quiet => false }
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

    it "should follow parent (../../) relative paths" do
      gen = Generator.new
      gen.options[:project_root] = fixture "shared/vectors"
      path = gen.expand_path "../../generators"
      path.should == fixture("generators")
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

    #it "should output a message"
  end

  #context "#garbage_collect" do
    #it "should delete files from passed array"
    #it "should update the manifest after completion"
  #end

  context "#get_manifest" do
    it "should return a manifest hash" do
      gen = Generator.new
      options = { :project_root => fixture("generators"), :manifest => fixture("generators/.fontcustom-manifest.json") }
      gen.instance_variable_set :@options, options
      gen.get_manifest.keys.should == manifest_contents.keys
    end

    it "should raise an error if the file is empty" do
      gen = Generator.new
      options = { :project_root => fixture("generators"), :manifest => fixture("generators/.fontcustom-manifest-empty.json") }
      gen.instance_variable_set :@options, options
      expect { gen.get_manifest }.to raise_error Fontcustom::Error, /Couldn't parse/
    end

    it "should raise an error if the file is corrupted" do
      gen = Generator.new
      options = { :project_root => fixture("generators"), :manifest => fixture("generators/.fontcustom-manifest-corrupted.json") }
      gen.instance_variable_set :@options, options
      expect { gen.get_manifest }.to raise_error Fontcustom::Error, /Couldn't parse/
    end
  end

  context "#set_manifest" do
    it "should update the manifest" do
      gen = Generator.new
      options = { :manifest => fixture("generators/.fontcustom-manifest.json") }
      gen.instance_variable_set :@options, options
      contents = manifest_contents.merge :checksum => "123"
      gen.should_receive(:write_file).with(options[:manifest], /"checksum":\s+"123"/, :update)
      gen.set_manifest :checksum, "123"
    end
  end

  context "#relative_to_root" do
    it "should trim project root from paths" do
      gen = Generator.new
      path = gen.relative_to_root fixture "test/path"
      path.should == "test/path"
    end

    it "should trim beginning slash" do
      gen = Generator.new
      path = gen.relative_to_root "/test/path"
      path.should == "test/path"
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
