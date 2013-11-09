require "spec_helper"

describe Fontcustom::Generator::Manifest do
  before(:each) do
    Fontcustom::Options.any_instance.stub :say_message
  end

  #context "#update_or_create_manifest" do
    #it "should call .update_manifest if manifest exists"
    #it "should call .create_manifest if manifest doesn't exist"
  #end

  #context ".update_manifest" do
    #it "should update manifest with changed options"
    #it "should do nothing if options are the same"
  #end

  #context ".create_manifest" do
    #it "should create a manifest with options"
  #end
end
