require "spec_helper"

describe Fontcustom::Generator::Font do
  def generator
    Fontcustom::Manifest.any_instance.stub :write_file
    Fontcustom::Generator::Font.new("")
  end

  context "#generate" do
    it "should set manifest[:glyphs] (integration)", :integration => true do
      live_test do |testdir|
        test_manifest
        manifest = File.join Dir.pwd, ".fontcustom-manifest.json"
        gen = Fontcustom::Generator::Font.new manifest
        gen.stub :create_fonts
        gen.generate
        File.read(manifest).should match(/"glyphs":.+"C":/m)
      end
    end

    it "should generate fonts (integration)", :integration => true do
      live_test do |testdir|
        test_manifest
        manifest = File.join Dir.pwd, ".fontcustom-manifest.json"
        Fontcustom::Generator::Font.new(manifest).generate
        Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length.should == 4
        File.read(manifest).should match(/"fonts":.*fontcustom\/fontcustom_.+\.ttf"/m)
      end
    end
  end

  context ".create_output_dirs" do
    it "should create empty dirs if they don't exist" do
      gen = generator
      options = {
        :output => {:fonts => "path/fonts", :vectors => "path/vectors"},
        :quiet => true
      }
      gen.instance_variable_set :@options, options
      gen.should_receive(:empty_directory).with("path/fonts", :verbose => false)
      gen.should_receive(:empty_directory).with("path/vectors", :verbose => false)
      gen.send :create_output_dirs
    end
  end

  context ".set_glyph_info" do
    it "should set :glyphs in manifest" do
      gen = generator
      gen.instance_variable_set :@options, :input => {:vectors => fixture("shared/vectors")}
      manifest = gen.instance_variable_get(:@manifest)

      gen.send :set_glyph_info
      data = manifest.instance_variable_get(:@data)
      data[:glyphs][:C].should include(:codepoint => 61696)
      data[:glyphs][:D].should include(:codepoint => 61697)
      data[:glyphs][:"a_R3ally-eXotic-f1Le-Name"].should include(:codepoint => 61698)
    end

    it "should not change codepoints of existing glyphs" do
      gen = generator
      gen.instance_variable_set :@options, :input => {:vectors => fixture("shared/vectors")}
      manifest = gen.instance_variable_get(:@manifest)
      manifest.set :glyphs, {:C => {:source => "foo", :codepoint => 61699}}

      gen.send :set_glyph_info
      data = manifest.instance_variable_get(:@data)
      data[:glyphs][:C].should include(:codepoint => 61699)
      data[:glyphs][:D].should include(:codepoint => 61700)
      data[:glyphs][:"a_R3ally-eXotic-f1Le-Name"].should include(:codepoint => 61701)
    end
  end
end
