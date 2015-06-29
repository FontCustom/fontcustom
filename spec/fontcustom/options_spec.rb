# encoding: utf-8
require 'spec_helper'

describe Fontcustom::Options do
  def options(args = {})
    args[:manifest] = fixture('.fontcustom-manifest.json') if args[:manifest].nil?
    Fontcustom::Options.new(args)
  end

  before(:each) do
    allow_any_instance_of(Fontcustom::Options).to receive(:say_message)
    allow_any_instance_of(Fontcustom::Options).to receive(:parse_options)
  end

  context '.overwrite_examples' do
    it 'should overwite example defaults with real defaults' do
      o = options Fontcustom::EXAMPLE_OPTIONS.dup
      o.send :overwrite_examples
      cli = o.instance_variable_get(:@cli_options)
      Fontcustom::EXAMPLE_OPTIONS.keys.each do |key|
        expect(cli[key]).to eq(Fontcustom::DEFAULT_OPTIONS[key])
      end
    end
  end

  context '.set_config_path' do
    context 'when :config is set' do
      it "should use options[:config] if it's a file" do
        o = options config: 'options/any-file-name.yml'
        o.send :set_config_path
        expect(o.instance_variable_get(:@cli_options)[:config]).to eq('options/any-file-name.yml')
      end

      it 'should search for fontcustom.yml if options[:config] is a dir' do
        o = options config: 'options/config-is-in-dir'
        o.send :set_config_path
        expect(o.instance_variable_get(:@cli_options)[:config]).to eq('options/config-is-in-dir/fontcustom.yml')
      end

      it "should raise error if :config doesn't exist" do
        o = options config: 'does-not-exist'
        expect { o.send :set_config_path }.to raise_error Fontcustom::Error, /configuration file/
      end
    end

    context 'when :config is not set' do
      it 'should find fontcustom.yml in the same dir as the manifest' do
        FileUtils.cd fixture('options') do
          o = options
          o.send :set_config_path
          expect(o.instance_variable_get(:@cli_options)[:config]).to eq('fontcustom.yml')
        end
      end

      it 'should find fontcustom.yml at config/fontcustom.yml' do
        FileUtils.cd fixture('options/rails-like') do
          o = options
          o.send :set_config_path
          expect(o.instance_variable_get(:@cli_options)[:config]).to eq('config/fontcustom.yml')
        end
      end

      it 'should be false if nothing is found' do
        o = options manifest: 'options/no-config-here/.fontcustom-manifest.json'
        o.send :set_config_path
        expect(o.instance_variable_get(:@cli_options)[:config]).to eq(false)
      end
    end
  end

  context '.load_config' do
    it 'should warn if fontcustom.yml is blank' do
      o = options
      o.instance_variable_set :@cli_options, config: fixture('options/fontcustom-empty.yml')
      expect(o).to receive(:say_message).with :warn, /was empty/
      o.send :load_config
    end

    it "should raise error if fontcustom.yml isn't valid" do
      o = options
      o.instance_variable_set :@cli_options, config: fixture('options/fontcustom-malformed.yml')
      expect { o.send :load_config }.to raise_error Fontcustom::Error, /Error parsing/
    end

    it 'should assign empty hash :config is false' do
      o = options
      o.instance_variable_set :@cli_options, config: false
      o.send :load_config
      expect(o.instance_variable_get(:@config_options)).to eq({})
    end

    context 'when :debug is true' do
      it "should report which configuration file it's using" do
        o = options
        o.instance_variable_set :@cli_options,           config: fixture('options/any-file-name.yml'),
          debug: true
        expect(o).to receive(:say_message).with :debug, /Using settings/
        o.send :load_config
      end
    end
  end

  context '.merge_options' do
    it 'should overwrite defaults with config options' do
      o = options
      o.instance_variable_set :@config_options, input: 'config'
      o.send :merge_options
      expect(o.options[:input]).to eq('config')
    end

    it 'should overwrite config file and defaults with CLI options' do
      o = options
      o.instance_variable_set :@config_options, input: 'config', output: 'output'
      o.instance_variable_set :@cli_options, input: 'cli'
      o.send :merge_options
      expect(o.options[:input]).to eq('cli')
      expect(o.options[:output]).to eq('output')
    end
  end

  context '.clean_font_name' do
    it 'should normalize the font name' do
      o = options
      o.instance_variable_set :@options, font_name: ' A_stR4nG3  nAm3 Ø&  '
      o.send :clean_font_name
      expect(o.options[:font_name]).to eq('A_stR4nG3--nAm3---')
    end
  end

  context '.set_input_paths' do
    it "should raise error if input[:vectors] doesn't contain SVGs" do
      FileUtils.cd fixture('shared') do
        o = options
        o.instance_variable_set :@options, input: 'vectors-empty'
        expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /doesn't contain any SVGs/
      end
    end

    context 'when :input is a hash' do
      it "should set :templates as :vectors if :templates isn't set" do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options, input: { vectors: 'vectors' }
          o.send :set_input_paths
          expect(o.options[:input][:templates]).to eq('vectors')
        end
      end

      it "should preserve :templates if it's set" do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options, input: { vectors: 'vectors', templates: 'templates' }
          o.send :set_input_paths
          expect(o.options[:input][:templates]).to eq('templates')
        end
      end

      it "should raise an error if :vectors isn't set" do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options, input: { templates: 'templates' }
          expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /have a :vectors key/
        end
      end

      it "should raise an error if :vectors doesn't point to an existing directory" do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options,             config: 'fontcustom.yml',
            input: { vectors: 'not-a-dir' }
          expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /isn't a directory/
        end
      end
    end

    context 'when :input is a string' do
      it 'should return a hash of locations' do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options, input: 'vectors'
          o.send :set_input_paths
          expect(o.options[:input]).to have_key(:vectors)
          expect(o.options[:input]).to have_key(:templates)
        end
      end

      it 'should set :templates to match :vectors' do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options, input: 'vectors'
          o.send :set_input_paths
          expect(o.options[:input][:templates]).to eq('vectors')
        end
      end

      it "should raise an error if :vectors doesn't point to a directory" do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options,             config: 'fontcustom.yml',
            input: 'not-a-dir'
          expect { o.send :set_input_paths }.to raise_error Fontcustom::Error, /isn't a directory/
        end
      end
    end
  end

  context '.set_output_paths' do
    context 'when :output is nil' do
      context 'when :debug is true' do
        it 'should print a warning' do
          o = options
          o.instance_variable_set :@options,             debug: true,
            font_name: 'Test-Font'
          expect(o).to receive(:say_message).with :debug, /Test-Font/
          o.send :set_output_paths
        end
      end
    end

    context 'when :output is a hash' do
      it "should set :css and :preview to match :fonts if either aren't set" do
        o = options
        o.instance_variable_set :@options, output: { fonts: 'output/fonts' }
        o.send :set_output_paths
        expect(o.options[:output][:css]).to eq('output/fonts')
        expect(o.options[:output][:preview]).to eq('output/fonts')
      end

      it 'should preserve :css and :preview if they do exist' do
        o = options
        o.instance_variable_set :@options,           output: {
          fonts: 'output/fonts',
            css: 'output/styles',
            preview: 'output/preview'
        }
        o.send :set_output_paths
        expect(o.options[:output][:css]).to eq('output/styles')
        expect(o.options[:output][:preview]).to eq('output/preview')
      end

      it 'should create additional paths if they are given' do
        o = options
        o.instance_variable_set :@options,           output: {
          :fonts => 'output/fonts',
            'special.js' => 'assets/javascripts'
        }
        o.send :set_output_paths
        expect(o.options[:output][:"special.js"]).to eq('assets/javascripts')
      end

      it "should raise an error if :fonts isn't set" do
        o = options
        o.instance_variable_set :@options,           config: 'fontcustom.yml',
          output: { css: 'output/styles' }
        expect { o.send :set_output_paths }.to raise_error Fontcustom::Error, /have a :fonts key/
      end
    end

    context 'when :output is a string' do
      it 'should return a hash of output locations' do
        o = options
        o.instance_variable_set :@options, output: 'output/fonts'
        o.send :set_output_paths
        expect(o.options[:output]).to be_a(Hash)
        expect(o.options[:output]).to have_key(:fonts)
        expect(o.options[:output]).to have_key(:css)
        expect(o.options[:output]).to have_key(:preview)
      end

      it 'should set :css and :preview to match :fonts' do
        o = options
        o.instance_variable_set :@options, output: 'output/fonts'
        o.send :set_output_paths
        expect(o.options[:output][:css]).to eq('output/fonts')
        expect(o.options[:output][:preview]).to eq('output/fonts')
      end

      it "should raise an error if :fonts exists but isn't a directory" do
        FileUtils.cd fixture('shared') do
          o = options
          o.instance_variable_set :@options,             config: 'fontcustom.yml',
            output: 'not-a-dir'
          expect { o.send :set_output_paths }.to raise_error Fontcustom::Error, /isn't a directory/
        end
      end
    end
  end

  context '.check_template_paths' do
    it 'should raise an error if a template does not exist' do
      o = options
      o.instance_variable_set :@options,         input: { templates: fixture('shared/templates') },
        templates: %w(fake-template.txt)
      expect { o.send :check_template_paths }.to raise_error Fontcustom::Error, /wasn't found/
    end
  end
end
