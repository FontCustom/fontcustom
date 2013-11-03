require "json"

# Requires access to @manifest
module Fontcustom
  module Utility
    def symbolize_hash(hash)
      hash.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
    end

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
