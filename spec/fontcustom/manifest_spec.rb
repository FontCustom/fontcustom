require 'spec_helper'

describe Fontcustom::Manifest do
  context '#initialize' do
    it 'should create a manifest file and assign :options', integration: true do
      live_test do |testdir|
        capture(:stdout) do
          manifest = File.join testdir, '.fontcustom-manifest.json'
          options = Fontcustom::Options.new(manifest: manifest, input: 'vectors').options
          Fontcustom::Manifest.new manifest, options
        end
        content = File.read File.join(testdir, '.fontcustom-manifest.json')
        expect(content).to match(/"options":.+"input":/m)
      end
    end
  end
end
