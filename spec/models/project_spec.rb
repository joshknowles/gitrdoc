# == Schema Info
# Schema version: 20090510014855
#
# Table name: projects
#
#  id                       :integer         not null, primary key
#  error_cloning_repository :boolean
#  name                     :string(255)
#  user_name                :string(255)
#  created_at               :datetime
#  repository_cloned_at     :datetime
#  updated_at               :datetime

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Project do
  describe "Associations" do
    it { should have_many(:references).dependent(:destroy) }
    it { should have_many(:revisions).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:user_name) }
    it { should validate_presence_of(:name) }
    it { pending "Patch Shoulda to not hit database for uniqueness check"; should validate_uniqueness_of(:name) }
  end

  describe "Callbacks" do
    before :each do
      @project = new_project
    end

    describe "after_create" do
      it "should queue a clone of the repository" do
        @project.should_receive(:send_later).with(:clone_repository)
        @project.send(:callback, :after_create)
      end
    end

    describe "after_destroy" do
      it "should delete the cloned repository" do
        FileUtils.should_receive(:rm_rf).with(@project.repository_path)
        @project.send(:callback, :after_destroy)
      end
    end
  end

  describe "Instance Methods" do
    before :each do
      @project = new_project
    end

    describe "repository_url" do
      specify { @project.repository_url.should == "git://github.com/#{@project.user_name}/#{@project.name}.git" }

      it "should raise an error if user_name is blank" do
        @project.user_name = nil
        lambda { @project.repository_url }.should raise_error
      end

      it "should raise an error if name is blank" do
        @project.name = nil
        lambda { @project.repository_url }.should raise_error
      end
    end

    describe "repository_path" do
      specify { @project.repository_path.should == File.join(GitRDoc.repository_root, @project.user_name, @project.name) }

      it "should raise an error if user_name is blank" do
        @project.user_name = nil
        lambda { @project.repository_path }.should raise_error
      end

      it "should raise an error if name is blank" do
        @project.name = nil
        lambda { @project.repository_path }.should raise_error
      end
    end

    describe "rdoc_path" do
      specify { @project.rdoc_path.should == File.join(GitRDoc.rdoc_root, @project.user_name, @project.name) }

      it "should raise an error if user_name is blank" do
        @project.user_name = nil
        lambda { @project.rdoc_path }.should raise_error
      end

      it "should raise an error if name is blank" do
        @project.name = nil
        lambda { @project.rdoc_path }.should raise_error
      end
    end

    describe "clone_repository" do
      before :each do
        @project.stub!(:update_attribute)
      end

      it "should raise an error if the repository has already been cloned" do
        @project.repository_cloned_at = Time.now
        lambda { @project.clone_repository }.should raise_error
      end

      it "should clone the git repository at the given url into the repository path" do
        GitRDoc::Git::Repository.should_receive(:clone).with(@project.repository_url, @project.repository_path)
        @project.clone_repository
      end

      context "clone is successful" do
        before :each do
          GitRDoc::Git::Repository.stub!(:clone).and_return(true)
        end

        it "should set repository_cloned_at to the current datetime" do
          current_time = Time.now
          Time.stub!(:now).and_return(current_time)
          @project.should_receive(:update_attribute).with(:repository_cloned_at, current_time)
          @project.clone_repository
        end
      end

      context "clone is unsuccessful" do
        before :each do
          GitRDoc::Git::Repository.stub!(:clone).and_return(false)
        end

        it "should set error_cloning_repository to true" do
          @project.should_receive(:update_attribute).with(:error_cloning_repository, true)
          @project.clone_repository
        end
      end
    end

    describe "has_cloned_repository?" do
      it "should be true if repository_cloned_at has been set" do
        @project.repository_cloned_at = Time.now
        @project.should have_cloned_repository
      end

      it "should be false if repository_cloned_at has not been set" do
        @project.repository_cloned_at = nil
        @project.should_not have_cloned_repository
      end
    end

    describe "revision" do
      it "should raise an error if the repository hasn't been cloned" do
        @project.repository_cloned_at = nil
        lambda { @project.revision("master") }.should raise_error
      end

      context "repository has been cloned" do
        before :each do
          @project.repository_cloned_at = Time.now
        end

        context "reference is unknown" do
          before :each do
            @project.references.stub!(:find_by_name => nil)
          end

          context "reference is invalid" do
            it "should return nil" do
              GitRDoc::Git::Repository.should_receive(:revision).with(@project.repository_path, "invalid").and_return(nil)
              @project.revision("invalid").should be_nil
            end
          end

          context "reference is valid" do
            before :each do
              GitRDoc::Git::Repository.should_receive(:revision).with(@project.repository_path, "master").and_return(:sha)
              @reference = stub_model(Reference, :name => "master", :sha => :sha)
              @project.references.stub!(:create! => @reference)
              @project.revisions.stub!(:find_or_create_by_sha)
            end

            it "should create a Reference representing the given revision" do
              @project.references.should_receive(:create!)
              @project.revision("master")
            end

            it "should find or create a Revision model representing the reference's sha" do
              @project.revisions.should_receive(:find_or_create_by_sha).with(@reference.sha)
              @project.revision("master")
            end
          end
        end

        context "reference is known" do
          before :each do
            @reference = stub_model(Reference, :name => "master", :sha => :sha)
            @project.references.stub!(:find_by_name => @reference)
            @project.revisions.stub!(:find_or_create_by_sha)
          end

          it "shouldn't re-request the sha from the git repo" do
            GitRDoc::Git::Repository.should_not_receive(:revision)
            @project.revision("master")
          end

          it "should find or create a Revision representing the Reference's sha" do
            @project.revisions.should_receive(:find_or_create_by_sha).with(@reference.sha)
            @project.revision("master")
          end
        end
      end
    end

    describe "pull_repository_and_generate_rdoc" do
      before :each do
        @project.repository_cloned_at = Time.now
      end

      it "should raise an error if the repository hasn't been cloned" do
        @project.repository_cloned_at = nil
        lambda { @project.update }.should raise_error
      end

      it "should pull the latest git revisions into the repository path" do
        GitRDoc::Git::Repository.should_receive(:pull).with(@project.repository_path)
        @project.pull_repository_and_generate_rdoc
      end

      context "pull is successful" do
        before :each do
          GitRDoc::Git::Repository.stub!(:pull => true)
          GitRDoc::Git::Repository.stub!(:revision => :sha)

          @reference = stub_model(Reference)
          @reference.stub!(:update_attribute)

          @project.references.stub!(:find_or_initialize_by_name => @reference)

          @revision = stub_model(Revision)
          @revision.stub!(:generate_rdoc)

          @project.revisions.stub!(:find_by_sha => @revision)
          @project.revisions.stub!(:build => @revision)
        end

        it "should get the current SHA of the master branch of the repository" do
          GitRDoc::Git::Repository.should_receive(:revision).with(@project.repository_path, "master").and_return(:sha)
          @project.pull_repository_and_generate_rdoc
        end

        it "should find or initialize a master Reference" do
          @project.references.should_receive(:find_or_initialize_by_name).with("master")
          @project.pull_repository_and_generate_rdoc
        end

        it "should update the sha of the Reference" do
          @reference.should_receive(:update_attribute).with(:sha, :sha)
          @project.pull_repository_and_generate_rdoc
        end

        context "reivsion already exists" do
          before :each do
            @revisions.stub!(:find_by_sha => @revision)
          end

          it "should not generate a new revision" do
            @project.revisions.should_not_receive(:build)
            @project.pull_repository_and_generate_rdoc
          end

          it "should not re-generate the rdoc" do
            @revision.should_not_receive(:generate_rdoc)
            @project.pull_repository_and_generate_rdoc
          end
        end

        context "revision does not yet exist" do
          before :each do
            @project.revisions.stub!(:find_by_sha => nil)
          end

          it "should initialize a new Revision" do
            @project.revisions.should_receive(:build)
            @project.pull_repository_and_generate_rdoc
          end

          it "should generate the RDoc" do
            @revision.should_receive(:generate_rdoc)
            @project.pull_repository_and_generate_rdoc
          end
        end
      end

      context "pull is unsuccessful" do
        before :each do
          GitRDoc::Git::Repository.stub!(:pull).and_return(false)
        end

        it "should not create a new Revision" do
          @project.revisions.should_not_receive(:find_or_initialize_by_sha)
          @project.pull_repository_and_generate_rdoc
        end
      end
    end

    describe "url" do
      specify { @project.url.should ==  "http://github.com/#{@project.user_name}/#{@project.name}/tree/master" }

      it "should raise an error if user_name is blank" do
        @project.user_name = nil
        lambda { @project.url }.should raise_error
      end

      it "should raise an error if name is blank" do
        @project.name = nil
        lambda { @project.url }.should raise_error
      end
    end

    describe "to_s" do
      it { @project.to_s.should == "#{@project.user_name}-#{@project.name}"}
    end
  end
end
