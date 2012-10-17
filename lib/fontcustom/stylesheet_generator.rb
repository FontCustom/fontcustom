require 'thor/group'

module Fontcustom
  class StylesheetGenerator < Thor::Group
    include Thor::Actions

    desc 'Generates a stylesheet with @font-face includes and ".icon-#{name}" classes.'

    argument :opts, :type => :hash

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_directory
      empty_directory(opts[:output])
    end

    def create_stylesheet
      template('templates/fontcustom.css', opts[:output] + '/fontcustom.css')
    end
  end
end
