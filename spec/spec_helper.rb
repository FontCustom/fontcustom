require 'spork'

Spork.prefork do
  require 'rspec'
  require 'fileutils'

  RSpec.configure do |c|
    def cleanup(dir)
      FileUtils.rm_r dir
    end
  end
end

Spork.each_run do
  require File.expand_path('../../lib/fontcustom.rb', __FILE__)
end
