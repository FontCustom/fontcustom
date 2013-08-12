require 'spec_helper'

describe Fontcustom::Actions do
  class Generator
    include Fontcustom::Actions
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
end
