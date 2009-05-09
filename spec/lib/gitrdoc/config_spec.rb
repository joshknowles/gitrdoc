require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe GitRDoc::Config do
  specify { GitRDoc::Config.new.repository_root.should == File.join(RAILS_ROOT, "tmp", "repositories") }
end
