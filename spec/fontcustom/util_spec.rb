require 'spec_helper'

describe Fontcustom::Util do
  class Generator
    include Fontcustom::Util
    attr_accessor :opts

    def initialize
      @opts = { :project_root => fixture, :verbose => true }
      @shell = Thor::Shell::Color.new
    end
  end

  context "#say_changed" do
    it "should strip :project_root from changed paths" do
      changed = %w|a b c|.map { |file| fixture(file) }
      gen = Generator.new
      output = capture(:stdout) { gen.say_changed(:success, changed) }
      output.should_not match(fixture)
    end
  end

  context "#check_fontforge" do
    it "should raise error if fontforge isn't installed" do
      gen = Generator.new
      gen.stub(:"`").and_return("")
      expect { gen.check_fontforge }.to raise_error Fontcustom::Error, /install fontforge/
    end
  end
end
