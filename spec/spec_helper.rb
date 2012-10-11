require 'spork'

Spork.prefork do
  require 'rspec'
  require 'fileutils'
  require File.expand_path('../../lib/fontcustom.rb', __FILE__)

  RSpec.configure do |c|
    def cleanup(dir)
      FileUtils.rm_r dir
    end
  end
end

Spork.each_run do

end
