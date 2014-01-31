require "spec_helper"

describe Fontcustom::Generator::Template do
  context "#generate" do
    it "should generate templates (integration)", :integration => true do
      live_test do |testdir|
        FileUtils.cp_r fixture("generators/mixed-output"), "fontcustom"
        test_manifest(
          :input => "vectors", 
          :quiet => true,
          :templates => %w|preview css scss scss-rails|
        )
        manifest = File.join testdir, ".fontcustom-manifest.json"
        Fontcustom::Generator::Font.new(manifest).generate
        Fontcustom::Generator::Template.new(manifest).generate

        content = File.read manifest
        content.should match(/fontcustom\/fontcustom-preview.html/)
      end
    end
  end

  context ".set_relative_paths" do
    it "should assign @font_path, @font_path_alt, and @font_path_preview" do
      gen = Fontcustom::Generator::Template.new fixture("generators/.fontcustom-manifest.json")
      options = gen.instance_variable_get :@options
      options[:output] = {:fonts => fixture("sandbox/test/fonts"), :css => fixture("sandbox/test/css"), :preview => fixture("sandbox/test")}

      gen.send :set_relative_paths
      gen.instance_variable_get(:@font_path).should match("../fonts")
      gen.instance_variable_get(:@font_path_alt).should match("../fonts")
      gen.instance_variable_get(:@font_path_preview).should match(".")
    end

    it "should assign @font_path_alt if :preprocessor_path is set" do
      gen = Fontcustom::Generator::Template.new fixture("generators/.fontcustom-manifest.json")
      options = gen.instance_variable_get :@options
      options[:preprocessor_path] = "fonts/fontcustom"
      options[:output] = {:fonts => fixture("sandbox/test/fonts"), :css => fixture("sandbox/test/css"), :preview => fixture("sandbox/test")}

      gen.send :set_relative_paths
      gen.instance_variable_get(:@font_path_alt).should match("fonts/fontcustom")
    end

    it "should assign @font_path_alt as bare font name if :preprocessor_path is false" do
      gen = Fontcustom::Generator::Template.new fixture("generators/.fontcustom-manifest.json")
      options = gen.instance_variable_get :@options
      options[:preprocessor_path] = false
      options[:output] = {:fonts => fixture("sandbox/test/fonts"), :css => fixture("sandbox/test/css"), :preview => fixture("sandbox/test")}

      gen.send :set_relative_paths
      gen.instance_variable_get(:@font_path_alt).should_not match("../fonts")
    end

    it "should assign '.' when paths are the same" do
      gen = Fontcustom::Generator::Template.new fixture("generators/.fontcustom-manifest.json")
      options = gen.instance_variable_get :@options
      options[:output] = {:fonts => fixture("sandbox/test/fonts"), :css => fixture("sandbox/test/fonts"), :preview => fixture("sandbox/test/fonts")}

      gen.send :set_relative_paths
      gen.instance_variable_get(:@font_path).should match("./")
    end
  end
end
