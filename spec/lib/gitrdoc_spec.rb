require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe GitRDoc do
  before :each do
    @_config = GitRDoc.config
  end

  after :each do
    GitRDoc.configure(@_config)
  end

  it "should proxy missing methods to the config" do
    config = mock("config")
    config.should_receive(:respond_to?).with(:attribute).and_return(true)
    config.should_receive(:attribute).and_return(:value)

    GitRDoc.configure(config)

    GitRDoc.attribute.should == :value
  end
end
