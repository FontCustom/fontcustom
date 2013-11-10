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
        File.read(manifest).should match(/"glyphs":.+"c":/m)
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

  context ".delete_old_fonts" do
    #it "should delete all fonts in @manifest[:fonts]"

    it "should clear :fonts from manifest" do
      gen = generator
      gen.stub :say_changed
      manifest = {:fonts => %w|fonts/a.ttf fonts/a.eot fonts/a.woff fonts/a.svg|}
      gen.instance_variable_set :@manifest, manifest
      gen.should_receive(:set_manifest).with(:fonts, [])
      gen.send :delete_old_fonts
      gen.instance_variable_get(:@manifest)[:fonts].should == []
    end
  end

  context ".set_glyph_info" do
    it "should set :glyphs in manifest" do
      gen = generator
      options = {:input => {:vectors => fixture("shared/vectors")}}
      manifest = {:glyphs => {}}
      gen.instance_variable_set :@options, options
      gen.instance_variable_set :@manifest, manifest
      gen.should_receive(:set_manifest).with(:glyphs, {
        :"a_r3ally-exotic-f1le-name" => hash_including(:codepoint => 61696),
        :c => hash_including(:codepoint => 61697),
        :d => hash_including(:codepoint => 61698)
      })
      gen.send :set_glyph_info
    end

    it "should not change codepoints of existing glyphs" do
      gen = generator
      options = {:input => {:vectors => fixture("shared/vectors")}}
      manifest = {:glyphs => {:c => {:source => "foo", :codepoint => 61699}}}
      gen.instance_variable_set :@options, options
      gen.instance_variable_set :@manifest, manifest
      gen.should_receive(:set_manifest).with(:glyphs, {
        :"a_r3ally-exotic-f1le-name" => hash_including(:codepoint => 61700),
        :c => hash_including(:codepoint => 61699),
        :d => hash_including(:codepoint => 61701)
      })
      gen.send :set_glyph_info
    end
  end

  context ".run_fontforge" do
  end
end
