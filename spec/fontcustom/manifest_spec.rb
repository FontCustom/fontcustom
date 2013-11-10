require "spec_helper"

describe Fontcustom::Manifest do
  before(:each) do
    Fontcustom::Options.any_instance.stub :say_message
    Fontcustom::Manifest.stub :update_or_create_manifest
  end

  def generator(options = {})
    Fontcustom::Manifest.new options
  end

  #context ".update_manifest" do
    #it "should update manifest with changed options"
    #it "should do nothing if options are the same"
  #end

  #context ".create_manifest" do
    #it "should create a manifest with options"
  #end
end
