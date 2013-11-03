require "json"

# Requires access to @manifest
module Fontcustom
  module Utility
    def get_manifest
      manifest = File.read @manifest
      if ! manifest.empty?
        JSON.parse(manifest, :symbolize_names => true)
      else
        # Empty manifest error
      end
    end

    def set_manifest(key, val)
    end
  end
end
