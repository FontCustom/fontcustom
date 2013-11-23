# encoding: utf-8
require "spec_helper"

describe Fontcustom::Options do
  def options(args = {})
    Fontcustom::Options.new(args)
  end

  before(:each) do
    Fontcustom::Options.any_instance.stub :say_message
    Fontcustom::Options.any_instance.stub :parse_options
  end

  context ".overwrite_examples" do
    it "should overwite example defaults with real defaults" do
      o = options(Fontcustom::EXAMPLE_OPTIONS.dup)
      o.send :overwrite_examples
      cli = o.instance_variable_get(:@cli_options)
      Fontcustom::EXAMPLE_OPTIONS.keys.each do |key|
        cli[key].should == Fontcustom::DEFAULT_OPTIONS[key] unless key == :project_root
      end
    end
  end

  context ".set_config_path" do
    context "when :config is set" do
      it "should use options[:config] if it's a file" do
        o = options(
          :project_root => fixture,
          :config => "options/any-file-name.yml"
        )
        o.send :set_config_path
        o.instance_variable_get(:@cli_options)[:config].should == fixture("options/any-file-name.yml")
      end

      it "should search for fontcustom.yml if options[:config] is a dir" do
        o = options(
          :project_root => fixture,
          :config => "options/config-is-in-dir"
        )
        o.send :set_config_path
        o.instance_variable_get(:@cli_options)[:config].should == fixture("options/config-is-in-dir/fontcustom.yml")
      end

      it "should raise error if :config doesn't exist" do
        o = options(
          :project_root => fixture,
          :config => "does-not-exist"
        )
        expect { o.send :set_config_path }.to raise_error Fontcustom::Error, /configuration file/
      end
    end

    context "when :config is not set" do
      it "should find fontcustom.yml at :project_root/fontcustom.yml" do
        o = options :project_root => fixture("options")
        o.send :set_config_path
        o.instance_variable_get(:@cli_options)[:config].should == fixture("options/fontcustom.yml")
      end

      it "should find fontcustom.yml at :project_root/config/fontcustom.yml" do
        o = options :project_root => fixture("options/rails-like")
        o.send :set_config_path
        o.instance_variable_get(:@cli_options)[:config].should == fixture("options/rails-like/config/fontcustom.yml")
      end

      it "should be false if nothing is found" do
        o = options :project_root => fixture("options/no-config-here")
        o.send :set_config_path
        o.instance_variable_get(:@cli_options)[:config].should == false
      end
    end
  end

  context ".load_config" do
    it "should warn if fontcustom.yml is blank" do
      o = options
      o.instance_variable_set :@cli_options, {
        :project_root => fixture,
        :config => fixture("options/fontcustom-empty.yml")
      }
      o.should_receive(:say_message).with :warn, /was empty/
      o.send :load_config
    end

    it "should raise error if fontcustom.yml isn't valid" do
      o = options
      o.instance_variable_set :@cli_options, {
        :project_root => fixture,
        :config => fixture("options/fontcustom-malformed.yml")
      }
      expect { o.send :load_config }.to raise_error Fontcustom::Error, /Error parsing/
    end

    it "should assign empty hash :config is false" do
      o = options
      o.instance_variable_set :@cli_options, {
        :project_root => fixture,
        :config => false
      }
      o.send :load_config
      o.instance_variable_get(:@config_options).should == {}
    end

    context "when :debug is true" do
      it "should report which configuration file it's using" do
        o = options
        o.instance_variable_set :@cli_options, {
          :project_root => fixture,
          :config => fixture("options/any-file-name.yml"),
          :debug => true
        }
        o.should_receive(:say_message).with :debug, /Using settings/
        o.send :load_config
      end
    end
  end

  context ".merge_options" do
    it "should overwrite defaults with config options" do
      o = options
      o.instance_variable_set :@config_options, { :input => "config" }
      o.send :merge_options
      o.options[:input].should == "config"
    end

    it "should overwrite config file and defaults with CLI options" do
      o = options
      o.instance_variable_set :@config_options, { :input => "config", :output => "output" }
      o.instance_variable_set :@cli_options, { :input => "cli" }
      o.send :merge_options
      o.options[:input].should == "cli"
      o.options[:output].should == "output"
    end
  end

  context ".clean_font_name" do
    it "should normalize the font name" do
      o = options
      o.options = { :font_name => " A_stR4nG3  nAm3 Ø&  " }
      o.send :clean_font_name
      o.options[:font_name].should == "A_stR4nG3--nAm3---"
    end
  end

  context ".set_manifest_path" do
    it "should set :manifest in the config dir by default" do
      o = options
      o.options = { :config => "path/to/config/fontcustom.yml" }
      o.send :set_manifest_path
      o.options[:manifest].should == "path/to/config/.fontcustom-manifest.json"
    end

    it "should set :manifest in :project_root if :config doesn't exist" do
      o = options
      o.options = { :project_root => "project/root" }
      o.send :set_manifest_path
      o.options[:manifest].should == "project/root/.fontcustom-manifest.json"
    end
  end

  context ".set_input_paths" do
    it "should raise error if input[:vectors] doesn't contain SVGs" do
      o = options
      o.options = {
        :project_root => fixture,
        :input => "shared/vectors-empty"
      }
      expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /doesn't contain any SVGs/
    end

    context "when :input is a hash" do
      it "should set :templates as :vectors if :templates isn't set" do
        o = options
        o.options = {
          :project_root => fixture,
          :input => { :vectors => "shared/vectors" }
        }
        o.send :set_input_paths
        o.options[:input][:templates].should == fixture("shared/vectors")
      end

      it "should preserve :templates if it's set" do
        o = options
        o.options = {
          :project_root => fixture,
          :input => { :vectors => "shared/vectors", :templates => "shared/templates" }
        }
        o.send :set_input_paths
        o.options[:input][:templates].should == fixture("shared/templates")
      end

      it "should raise an error if :vectors isn't set" do
        o = options
        o.options = {
          :project_root => fixture,
          :config => "fontcustom.yml",
          :input => { :templates => "shared/templates" }
        }
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /have a :vectors key/
      end

      it "should raise an error if :vectors doesn't point to an existing directory" do
        o = options
        o.options = {
          :project_root => fixture,
          :config => "fontcustom.yml",
          :input => { :vectors => "shared/not-a-dir" }
        }
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end

    context "when :input is a string" do
      it "should return a hash of locations" do
        o = options
        o.options = {
          :project_root => fixture,
          :input => "shared/vectors"
        }
        o.send :set_input_paths
        o.options[:input].should have_key(:vectors)
        o.options[:input].should have_key(:templates)
      end

      it "should set :templates to match :vectors" do
        o = options
        o.options = {
          :project_root => fixture,
          :input => "shared/vectors"
        }
        o.send :set_input_paths
        o.options[:input][:templates].should == fixture("shared/vectors")
      end

      it "should raise an error if :vectors doesn't point to a directory" do
        o = options
        o.options = {
          :project_root => fixture,
          :config => "fontcustom.yml",
          :input => "shared/not-a-dir"
        }
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end
  end

  context ".set_output_paths" do
    context "when :output is nil" do
      it "should default to :project_root/:font_name" do
        o = options
        o.options = {
          :project_root => fixture,
          :font_name => "Test-Font"
        }
        o.send :set_output_paths
        o.options[:output][:fonts].should == fixture("Test-Font")
      end

      context "when :debug is true" do
        it "should print a warning" do
          o = options
          o.options = {
            :project_root => fixture,
            :debug => true,
            :font_name => "Test-Font"
          }
          o.should_receive(:say_message).with :debug, /Test-Font/
          o.send :set_output_paths
        end
      end
    end

    context "when :output is a hash" do
      it "should set :css and :preview to match :fonts if either aren't set" do
        o = options
        o.options = {
          :project_root => fixture,
          :output => { :fonts => "output/fonts" }
        }
        o.send :set_output_paths
        o.options[:output][:css].should == fixture("output/fonts")
        o.options[:output][:preview].should == fixture("output/fonts")
      end

      it "should preserve :css and :preview if they do exist" do
        o = options
        o.options = {
          :project_root => fixture,
          :output => {
            :fonts => "output/fonts",
            :css => "output/styles",
            :preview => "output/preview"
          }
        }
        o.send :set_output_paths
        o.options[:output][:css].should == fixture("output/styles")
        o.options[:output][:preview].should == fixture("output/preview")
      end

      it "should create additional paths if they are given" do
        o = options
        o.options = {
          :project_root => fixture,
          :output => {
            :fonts => "output/fonts",
            "special.js" => "assets/javascripts"
          }
        }
        o.send :set_output_paths
        o.options[:output][:"special.js"].should == fixture("assets/javascripts")
      end

      it "should raise an error if :fonts isn't set" do
        o = options
        o.options = {
          :project_root => fixture,
          :config => "fontcustom.yml",
          :output => { :css => "output/styles" }
        }
        expect { o.send :set_output_paths }.to raise_error Fontcustom::Error, /have a :fonts key/
      end
    end

    context "when :output is a string" do
      it "should return a hash of output locations" do
        o = options
        o.options = {
          :project_root => fixture,
          :output => "output/fonts"
        }
        o.send :set_output_paths
        o.options[:output].should be_a(Hash)
        o.options[:output].should have_key(:fonts)
        o.options[:output].should have_key(:css)
        o.options[:output].should have_key(:preview)
      end

      it "should set :css and :preview to match :fonts" do
        o = options
        o.options = {
          :project_root => fixture,
          :output => "output/fonts"
        }
        o.send :set_output_paths
        o.options[:output][:css].should == fixture("output/fonts")
        o.options[:output][:preview].should == fixture("output/fonts")
      end

      it "should raise an error if :fonts exists but isn't a directory" do
        o = options
        o.options = {
          :project_root => fixture,
          :config => "fontcustom.yml",
          :output => "shared/not-a-dir"
        }
        expect { o.send :set_output_paths }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end
  end

  context ".set_template_paths" do
    it "should expand shorthand for packaged templates" do
      o = options
      o.options = {
        :project_root => fixture,
        :input => { :templates => "shared/templates" },
        :templates => %w|preview css scss scss-rails bootstrap bootstrap-scss bootstrap-ie7 bootstrap-ie7-scss|
      }
      o.send :set_template_paths
      o.options[:templates].should =~ [
        File.join(Fontcustom.gem_lib, "templates", "fontcustom-preview.html"),
        File.join(Fontcustom.gem_lib, "templates", "fontcustom.css"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom.scss"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom-rails.scss"),
        File.join(Fontcustom.gem_lib, "templates", "fontcustom-bootstrap.css"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom-bootstrap.scss"),
        File.join(Fontcustom.gem_lib, "templates", "fontcustom-bootstrap-ie7.css"),
        File.join(Fontcustom.gem_lib, "templates", "_fontcustom-bootstrap-ie7.scss")
      ]
    end

    it "should find custom templates in :template_path" do
      o = options
      o.options = {
        :project_root => fixture,
        :input => { :templates => fixture("shared/templates") },
        :templates => %w|custom.css|
      }
      o.send :set_template_paths
      o.options[:templates].should =~ [fixture("shared/templates/custom.css")]
    end

    it "should raise an error if a template does not exist" do
      o = options
      o.options = {
        :project_root => fixture,
        :input => { :templates => fixture("shared/templates") },
        :templates => %w|fake-template.txt|
      }
      expect { o.send :set_template_paths }.to raise_error Fontcustom::Error, /doesn't exist/
    end
  end
end
