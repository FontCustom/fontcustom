require 'spec_helper'

describe Fontcustom::Options do
  context '#parse_options' do
    it 'should return an options hash' do
      options = Fontcustom::Options.parse_options
      keys = [:font_name, :font_path, :input_dir, :output_dir, :css_template, :css_prefix, :hash, :html, :debug]

      options.should be_a_kind_of(Hash)
      (options.keys & keys).length.should equal(keys.length)
    end

    it 'should work without config file or CL args' do
      options = Fontcustom::Options.parse_options
      options[:font_name].should eq('fontcustom')
    end

    it 'should overwrite defaults from a config file' do
      options = Fontcustom::Options.parse_options(:config_file => fixture('fontcustom.yml'))
      options[:font_name].should eq('custom-name-from-config')
    end

    it 'should overwrite defaults and config with CL args' do
      options = Fontcustom::Options.parse_options(:font_name => 'custom-name-from-args', :config_file => fixture('fontcustom.yml'))
      options[:font_name].should eq('custom-name-from-args')
    end
  end
end
