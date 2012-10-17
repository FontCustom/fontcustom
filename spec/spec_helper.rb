require 'spork'

Spork.prefork do
  require 'rspec'
  require 'fileutils'

  RSpec.configure do |c|
    def cleanup(dir)
      FileUtils.rm_r(dir, :verbose => true) if File.exists?(dir)
    end

    def capture(stream)
      begin
        stream = stream.to_s
        eval "$#{stream} = StringIO.new"
        yield
        result = eval("$#{stream}").string
      ensure
        eval("$#{stream} = #{stream.upcase}")
      end

      result
    end
  end
end

Spork.each_run do
  require File.expand_path('../../lib/fontcustom.rb', __FILE__)
end
