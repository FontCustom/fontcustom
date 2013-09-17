require 'spec_helper'

describe Fontcustom::Options do
  def options(args = {})
    Fontcustom::Options.new(args)
  end

  def silent
    Fontcustom::Options.any_instance.stub :say_message
  end

  before(:each) { Fontcustom::Options.any_instance.stub(:set_options) }

  context "#initialize" do
    it "should overwite example defaults with real defaults" do
      # imitates the default hash passed by thor
      options = Fontcustom::Options.new(Fontcustom::EXAMPLE_OPTIONS.dup)
      options = options.instance_variable_get(:@cli_options)
      Fontcustom::EXAMPLE_OPTIONS.keys.each do |key|
        options[key].should == Fontcustom::DEFAULT_OPTIONS[key]
      end
    end
  end

  context ".set_config_path" do
    context "when :config is set" do
      it "should use options[:config] if it's a file" do
        args = {
          :project_root => fixture,
          :config => "options/any-file-name.yml"
        }
        o = options args
        o.send :set_config_path
        o.instance_variable_get(:@config).should == fixture("options/any-file-name.yml")
      end

      it "should search for fontcustom.yml if options[:config] is a dir" do
        args = {
          :project_root => fixture,
          :config => "options/config-is-in-dir"
        }
        o = options args
        o.send :set_config_path
        o.instance_variable_get(:@config).should == fixture("options/config-is-in-dir/fontcustom.yml")
      end

      it "should raise error if :config doesn't exist" do
        args = {
          :project_root => fixture,
          :config => "does-not-exist"
        }
        o = options args
        expect { o.send :set_config_path }.to raise_error Fontcustom::Error, /configuration file wasn't found/
      end
    end

    context "when :config is not set" do
      it "should find fontcustom.yml at :project_root/fontcustom.yml" do
        args = { :project_root => fixture("options") }
        o = options args
        o.send :set_config_path
        o.instance_variable_get(:@config).should == fixture("options/fontcustom.yml")
      end

      it "should find fontcustom.yml at :project_root/config/fontcustom.yml" do
        args = { :project_root => fixture("options/rails-like") }
        o = options args
        o.send :set_config_path
        o.instance_variable_get(:@config).should == fixture("options/rails-like/config/fontcustom.yml")
      end

      it "should be false if nothing is found" do
        args = { :project_root => fixture("options/no-config-here") }
        o = options args
        o.send :set_config_path
        o.instance_variable_get(:@config).should == false
      end
    end
  end

  context ".load_config" do
    def args
      { :project_root => fixture, :quiet => true }
    end

    it "should raise error if fontcustom.yml isn't valid" do
      o = options args
      o.instance_variable_set :@config, fixture("options/fontcustom-malformed.yml")
      expect { o.send :load_config }.to raise_error Fontcustom::Error, /failed to load/
    end

    it "should assign empty hash :config is false" do
      o = options args
      o.instance_variable_set :@config, false
      o.send :load_config
      o.instance_variable_get(:@config_options).should == {}
    end

    it "should assign empty hash if fontcustom.yml is blank" do
      o = options args
      o.instance_variable_set :@config, fixture("options/fontcustom-empty.yml")
      o.send :load_config
      o.instance_variable_get(:@config_options).should == {}
    end

    it "should report which configuration file it's using" do
      o = options
      o.instance_variable_set :@config, fixture("options/any-file-name.yml")
      stdout = capture(:stdout) { o.send :load_config }
      stdout.should match /options\/any-file-name\.yml/
    end

    it "should warn if no configuration file is used" do
      o = options
      o.instance_variable_set :@config, false
      stdout = capture(:stdout) { o.send :load_config }
      stdout.should match /No configuration/
    end
  end

  context ".merge_options" do
    before(:each) { silent }

    it "should set instance variables for each option key" do
      o = options
      o.instance_variable_set :@config_options, {}
      o.send :merge_options
      o.instance_variables.length.should == Fontcustom::DEFAULT_OPTIONS.length + 2 # @shell, @mock_proxy (rspec)
    end

    it "should overwrite defaults with config file" do
      o = options
      o.instance_variable_set :@config_options, { :input => "config" }
      o.send :merge_options
      o.instance_variable_get(:@input).should == "config"
    end

    it "should overwrite config file and defaults with CLI options" do
      o = options
      cli = o.instance_variable_get :@cli_options
      o.instance_variable_set :@config_options, { :input => "config", :output => "output" }
      o.instance_variable_set :@cli_options, cli.merge( :input => "cli" )
      o.send :merge_options
      o.instance_variable_get(:@input).should == "cli"
      o.instance_variable_get(:@output).should == "output"
    end

    it "should normalize the font name" do
      o = options
      o.instance_variable_set :@config_options, { :input => "config", :font_name => " A_stR4nG3  nAm3 Ø&  " }
      o.send :merge_options
      o.instance_variable_get(:@font_name).should == "A_stR4nG3--nAm3---"
    end
  end

  context ".set_data_path" do
    it "should set :data_cache in the config dir by default" do
      silent
      o = options
      o.instance_variable_set :@config, "path/to/config/fontcustom.yml"
      o.instance_variable_set :@data_cache, nil
      o.remove_instance_variable :@cli_options
      o.send :set_data_path
      o.instance_variable_get(:@data_cache).should == "path/to/config/.fontcustom-data"
    end
  end

  context "#send :set_input_paths" do
    it "should raise error if input[:vectors] doesn't contain vectors" do
      o = options
      o.instance_variable_set :@project_root, fixture
      o.instance_variable_set :@input, "shared/vectors-empty"
      o.remove_instance_variable :@cli_options
      expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /doesn't contain any vectors/
    end

    context "when @input is a hash" do
      it "should set :templates as :vectors if :templates isn't set" do
        hash = { :vectors => "shared/vectors" }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, hash
        o.remove_instance_variable :@cli_options
        o.send :set_input_paths
        input = o.instance_variable_get :@input
        input[:templates].should == fixture("shared/vectors")
      end

      it "should preserve :templates if it's set" do
        hash = { :vectors => "shared/vectors", :templates => "shared/templates" }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, hash
        o.remove_instance_variable :@cli_options
        o.send :set_input_paths
        input = o.instance_variable_get :@input
        input[:templates].should == fixture("shared/templates")
      end

      it "should raise an error if :vectors isn't set" do
        hash = { :templates => "shared/templates" }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, hash
        o.remove_instance_variable :@cli_options
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /contain a :vectors key/
      end

      it "should raise an error if :vectors doesn't point to an existing directory" do
        hash = { :vectors => "shared/not-a-dir" }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, hash
        o.remove_instance_variable :@cli_options
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end

    context "when @input is a string" do
      it "should return a hash of locations" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, "shared/vectors"
        o.remove_instance_variable :@cli_options
        o.send :set_input_paths
        input = o.instance_variable_get :@input
        input.should have_key(:vectors)
        input.should have_key(:templates)
      end

      it "should set :templates to match :vectors" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, "shared/vectors"
        o.remove_instance_variable :@cli_options
        o.send :set_input_paths
        input = o.instance_variable_get :@input
        input[:templates].should == fixture("shared/vectors")
      end

      it "should raise an error if :vectors doesn't point to a directory" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@input, "shared/not-a-dir"
        o.remove_instance_variable :@cli_options
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end
  end

  context ".set_output_paths" do
    context "when @output is nil" do
      it "should default to :project_root/:font_name" do
        silent
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@font_name, "Test-Font"
        o.instance_variable_set :@output, nil
        o.remove_instance_variable :@cli_options
        o.send :set_output_paths
        output = o.instance_variable_get :@output
        output[:fonts].should == fixture("Test-Font")
      end

      it "should print a warning" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@font_name, "Test-Font"
        o.instance_variable_set :@output, nil
        o.remove_instance_variable :@cli_options
        stdout = capture(:stdout) { o.send :set_output_paths }
        stdout.should match("Test-Font")
      end
    end

    context "when @output is a hash" do
      it "should set :css and :preview to match :fonts if either aren't set" do
        hash = { :fonts => "output/fonts" }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, hash
        o.remove_instance_variable :@cli_options
        o.send :set_output_paths
        output = o.instance_variable_get :@output
        output[:css].should == fixture("output/fonts")
        output[:preview].should == fixture("output/fonts")
      end

      it "should preserve :css and :preview if they do exist" do
        hash = {
          :fonts => "output/fonts",
          :css => "output/styles",
          :preview => "output/preview"
        }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, hash
        o.remove_instance_variable :@cli_options
        o.send :set_output_paths
        output = o.instance_variable_get :@output
        output[:css].should == fixture("output/styles")
        output[:preview].should == fixture("output/preview")
      end

      it "should create additional paths if they are given" do
        hash = {
          :fonts => "output/fonts",
          "special.js" => "assets/javascripts"
        }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, hash
        o.remove_instance_variable :@cli_options
        o.send :set_output_paths
        output = o.instance_variable_get :@output
        output[:"special.js"].should == fixture("assets/javascripts")
      end

      it "should raise an error if :fonts isn't set" do
        hash = { :css => "output/styles" }
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, hash
        o.remove_instance_variable :@cli_options
        expect { o.send :set_output_paths }.to raise_error Fontcustom::Error, /contain a :fonts key/
      end
    end

    context "when @output is a string" do
      it "should return a hash of output locations" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, "output/fonts"
        o.remove_instance_variable :@cli_options
        o.send :set_output_paths
        output = o.instance_variable_get :@output
        output.should be_a(Hash)
        output.should have_key(:fonts)
        output.should have_key(:css)
        output.should have_key(:preview)
      end

      it "should set :css and :preview to match :fonts" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, "output/fonts"
        o.remove_instance_variable :@cli_options
        o.send :set_output_paths
        output = o.instance_variable_get :@output
        output[:css].should == fixture("output/fonts")
        output[:preview].should == fixture("output/fonts")
      end

      it "should raise an error if :fonts exists but isn't a directory" do
        o = options
        o.instance_variable_set :@project_root, fixture
        o.instance_variable_set :@output, "shared/not-a-dir"
        o.remove_instance_variable :@cli_options
        expect { o.send :set_output_paths }.to raise_error Fontcustom::Error, /directory, not a file/
      end
    end
  end

  context ".set_template_paths" do
    it "should expand shorthand for packaged templates" do
      o = options
      o.instance_variable_set :@project_root, fixture
      o.instance_variable_set :@input, { :templates => "shared/templates" }
      o.instance_variable_set :@templates, %w|preview css scss bootstrap bootstrap-scss bootstrap-ie7 bootstrap-ie7-scss|
      o.remove_instance_variable :@cli_options
      o.send :set_template_paths
      templates = o.instance_variable_get :@templates
      templates.should =~ [
        File.join(Fontcustom.gem_lib, "templates", "fontcustom-preview.html"),
        File.join(Fontcustom.gem_lib, "templates", "fontcustom.css"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom.scss"),
        File.join(Fontcustom.gem_lib, "templates", "fontcustom-bootstrap.css"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom-bootstrap.scss"),
        File.join(Fontcustom.gem_lib, "templates", "fontcustom-bootstrap-ie7.css"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom-bootstrap-ie7.scss")
      ]
    end

    it "should find custom templates in :template_path" do
      o = options
      o.instance_variable_set :@project_root, fixture
      o.instance_variable_set :@input, { :templates => fixture("shared/templates") }
      o.instance_variable_set :@templates, %w|custom.css|
      o.remove_instance_variable :@cli_options
      o.send :set_template_paths
      templates = o.instance_variable_get :@templates
      templates.should =~ [fixture("shared/templates/custom.css")]
    end

    it "should raise an error if a template does not exist" do
      o = options
      o.instance_variable_set :@project_root, fixture
      o.instance_variable_set :@input, { :templates => "shared/templates" }
      o.instance_variable_set :@templates, %w|fake-template.txt|
      o.remove_instance_variable :@cli_options
      expect { o.send :set_template_paths }.to raise_error Fontcustom::Error, /does not exist/
    end
  end
end
