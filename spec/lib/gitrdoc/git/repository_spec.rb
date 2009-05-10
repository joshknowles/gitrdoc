require File.expand_path(File.join(File.dirname(__FILE__), "..", "..",  "..", "spec_helper"))

describe GitRDoc::Git::Repository do
  before :each do
    GitRDoc::Git::Repository.stub!(:system)
  end

  describe "clone" do
    it "should clone the git repository at the given url into the give repository path" do
      GitRDoc::Git::Repository.should_receive(:system).with("git clone repository_url repository_path")
      GitRDoc::Git::Repository.clone(:repository_url, :repository_path)
    end

    it "should return true if the clone succeeds" do
      GitRDoc::Git::Repository.should_receive(:system).and_return(true)
      GitRDoc::Git::Repository.clone(:repository_url, :repository_path).should == true
    end

    it "should return false if the clone fails" do
      GitRDoc::Git::Repository.should_receive(:system).and_return(false)
      GitRDoc::Git::Repository.clone(:repository_url, :repository_path).should == false
    end
  end

  describe "pull" do
    it "should change into the repository_path and pull from the origin master" do
      GitRDoc::Git::Repository.should_receive(:system).with("cd repository_path && git pull origin master")
      GitRDoc::Git::Repository.pull(:repository_path)
    end

    it "should return true if the pull succeeds" do
      GitRDoc::Git::Repository.should_receive(:system).and_return(true)
      GitRDoc::Git::Repository.pull(:repository_path).should == true
    end

    it "should return false if the pull fails" do
      GitRDoc::Git::Repository.should_receive(:system).and_return(false)
      GitRDoc::Git::Repository.pull(:repository_path).should == false
    end
  end

  describe "revision" do
    it "should return the sha for the revision of the repository at the given repository_path for the given reference" do
      mock_io = mock(:io)
      mock_io.should_receive(:read).and_return("ba661b250e167793fc9c21dd74393953c22601e1\n")

      IO.should_receive(:popen).with("cd repository_path && git rev-parse HEAD").and_return(mock_io)

      GitRDoc::Git::Repository.revision(:repository_path, "HEAD").should == "ba661b250e167793fc9c21dd74393953c22601e1"
    end

    it "should strip off the trailing new-line" do
      mock_io = mock(:io)
      mock_io.should_receive(:read).and_return("ba661b250e167793fc9c21dd74393953c22601e1\n")

      IO.should_receive(:popen).with("cd repository_path && git rev-parse HEAD").and_return(mock_io)

      GitRDoc::Git::Repository.revision(:repository_path, "HEAD").should == "ba661b250e167793fc9c21dd74393953c22601e1"
    end

    it "should treat 'master' as 'origin/master' to account for the repository being hard-reset to a different revision" do
      mock_io = mock(:io)
      mock_io.should_receive(:read).and_return("ba661b250e167793fc9c21dd74393953c22601e1\n")

      IO.should_receive(:popen).with("cd repository_path && git rev-parse origin/master").and_return(mock_io)

      GitRDoc::Git::Repository.revision(:repository_path, "master").should == "ba661b250e167793fc9c21dd74393953c22601e1"
    end

    it "should return nil if the reference is unknown" do
      mock_io = mock(:io)
      mock_io.should_receive(:read).and_return("unknown\n")

      IO.should_receive(:popen).with("cd repository_path && git rev-parse unknown").and_return(mock_io)

      GitRDoc::Git::Repository.revision(:repository_path, "unknown").should be_nil
    end
  end

  describe "reset" do
    it "should change into the repository_path and do a hard reset to the given reference" do
      GitRDoc::Git::Repository.should_receive(:system).with("cd repository_path && git reset --hard tag-name")
      GitRDoc::Git::Repository.reset(:repository_path, "tag-name")
    end

    it "should treat 'master' as 'origin/master' to account for the repository being hard-reset to a different revision" do
      GitRDoc::Git::Repository.should_receive(:system).with("cd repository_path && git reset --hard origin/master")
      GitRDoc::Git::Repository.reset(:repository_path, "master")
    end
  end
end