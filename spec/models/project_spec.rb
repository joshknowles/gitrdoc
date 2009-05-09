# == Schema Info
# Schema version: 20090509201408
#
# Table name: projects
#
#  id                       :integer         not null, primary key
#  master_revision_id       :integer
#  error_cloning_repository :boolean
#  name                     :string(255)
#  user_name                :string(255)
#  created_at               :datetime
#  repository_cloned_at     :datetime
#  updated_at               :datetime

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Project do
  describe "Associations" do
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

    describe "master_revision" do
      before :each do
        @revision = stub_model(Revision)
      end

      it "should raise an error if the repository hasn't been cloned" do
        @project.repository_cloned_at = nil
        lambda { @project.master_revision }.should raise_error
      end

      context "repository has been cloned" do
        before :each do
          @project.repository_cloned_at = Time.now
        end

        context "revision hasn't been created" do
          it "should find or create a Revision model representing the master revision of the repository and cache the id" do
            GitRDoc::Git::Repository.should_receive(:revision).with(@project.repository_path).and_return(:sha)
            @project.revisions.should_receive(:find_or_create_by_sha).with(:sha).and_return(@revision)
            @project.should_receive(:update_attribute).with(:master_revision_id, @revision.id)
            @project.master_revision.should == @revision
          end
        end

        context "revision has been created" do
          before :each do
            @project.master_revision_id = @revision.id
          end

          it "shouldn't re-request the sha from the git repo" do
            GitRDoc::Git::Repository.should_not_receive(:revision)
            @project.revisions.stub!(:find)
            @project.master_revision
          end

          it "should find the revision based on the master_revision_id" do
            @project.revisions.should_receive(:find).with(@revision.id)
            @project.master_revision.should == @revison
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
          GitRDoc::Git::Repository.stub!(:pull).and_return(true)
          GitRDoc::Git::Repository.stub!(:revision)

          @revision = stub_model(Revision, :project => @project)
          @revision.stub!(:rdoc_path)
          @revision.stub!(:url)
          @revision.stub!(:update_attribute)

          @project.revisions.stub!(:find_or_initialize_by_sha).and_return(@revision)

          GitRDoc::RDoc.stub!(:generate).and_return(true)

          @project.stub!(:update_attribute)
        end

        it "should find_or_initialize a Revision based on the current SHA of the repository" do
          GitRDoc::Git::Repository.should_receive(:revision).with(@project.repository_path).and_return(:sha)
          @project.revisions.should_receive(:find_or_initialize_by_sha).with(:sha)
          @project.pull_repository_and_generate_rdoc
        end

        it "should update the project's master_revision_id" do
          @project.should_receive(:update_attribute).with(:master_revision_id, @revision.id)
          @project.pull_repository_and_generate_rdoc
        end

        context "Revision hasn't already generated rdoc" do
          it "should build the rdoc" do
            @revision.stub!(:has_generated_rdoc? => false)

            current_time = Time.now
            Time.stub!(:now).and_return(current_time)

            GitRDoc::RDoc.should_receive(:generate).and_return(true)
            @revision.should_receive(:update_attribute).with(:rdoc_generated_at, current_time)

            @project.pull_repository_and_generate_rdoc
          end
        end

        context "Revision has already generated rdoc" do
          it "should not re-generate the rdoc" do
            @revision.stub!(:has_generated_rdoc? => true)

            GitRDoc::RDoc.should_not_receive(:generate)
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
