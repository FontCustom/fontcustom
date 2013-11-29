require "spec_helper"

describe Fontcustom::Generator::Font do
  def generator
    Fontcustom::Generator::Font.any_instance.stub(:get_manifest).and_return :options => {}
    Fontcustom::Generator::Font.new("")
  end

  context "#generate" do
    it "should set manifest[:glyphs] (integration)", :integration => true do
      live_test do |testdir|
        manifest = test_manifest
        gen = Fontcustom::Generator::Font.new manifest
        gen.stub :create_fonts
        gen.generate
        File.read(manifest).should match(/"glyphs":.+"C":/m)
      end
    end

    it "should generate fonts (integration)", :integration => true do
      live_test do |testdir|
        manifest = test_manifest
        Fontcustom::Generator::Font.new(manifest).generate
        Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length.should == 4
        File.read(manifest).should match(/"fonts":.+sandbox\/test\/fontcustom\/fontcustom_.+\.ttf"/m)
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
      gen.instance_variable_set :@manifest, :glyphs => {}

      gen.should_receive(:save_manifest)
      gen.send :set_glyph_info
      manifest = gen.instance_variable_get(:@manifest)
      manifest[:glyphs][:C].should include(:codepoint => 61696)
      manifest[:glyphs][:D].should include(:codepoint => 61697)
      manifest[:glyphs][:"a_R3ally-eXotic-f1Le-Name"].should include(:codepoint => 61698)
    end

    it "should not change codepoints of existing glyphs" do
      gen = generator
      gen.instance_variable_set :@options, :input => {:vectors => fixture("shared/vectors")}
      gen.instance_variable_set :@manifest, :glyphs => {:C => {:source => "foo", :codepoint => 61699}}

      gen.should_receive(:save_manifest)
      gen.send :set_glyph_info
      manifest = gen.instance_variable_get(:@manifest)
      manifest[:glyphs][:C].should include(:codepoint => 61699)
      manifest[:glyphs][:D].should include(:codepoint => 61700)
      manifest[:glyphs][:"a_R3ally-eXotic-f1Le-Name"].should include(:codepoint => 61701)
    end
  end

  #context ".run_fontforge" do
  #end
end
