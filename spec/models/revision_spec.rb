# == Schema Info
# Schema version: 20090509201408
#
# Table name: revisions
#
#  id                    :integer         not null, primary key
#  project_id            :integer
#  error_generating_rdoc :boolean
#  sha                   :string(255)
#  created_at            :datetime
#  rdoc_generated_at     :datetime
#  updated_at            :datetime

require File.dirname(__FILE__) + '/../spec_helper'

describe Revision do
  describe "Associations" do
    it { should belong_to(:project) }
  end

  describe "Validations" do
    it { should validate_presence_of(:project_id) }
    it { should validate_presence_of(:sha) }
    it { pending "Patch Shoulda to not hit database for uniqueness check"; should validate_uniqueness_of(:sha) }
  end

  describe "Callbacks" do
    before :each do
      @revision = new_revision
    end

    describe "after_create" do
      it "should queue a clone of the repository" do
        @revision.should_receive(:send_later).with(:generate_rdoc)
        @revision.send(:callback, :after_create)
      end
    end

    describe "after_destroy" do
      before :each do
        Project.stub!(:update_all)
        FileUtils.stub!(:rm_rf)
      end

      it "should nullify the foreign keys of all projects that this is a master revision for" do
        Project.should_receive(:update_all).with({ :master_revision_id => nil }, { :master_revision_id => @revision.id })
        @revision.send(:callback, :after_destroy)
      end

      it "should delete the generated rdoc" do
        FileUtils.should_receive(:rm_rf).with(@revision.rdoc_path)
        @revision.send(:callback, :after_destroy)
      end
    end
  end

  describe "Instance Methods" do
    before :each do
      @revision = new_revision
    end

    describe "rdoc_path" do
      specify { @revision.rdoc_path.should == File.join(@revision.project.rdoc_path, @revision.sha) }

      it "should raise an error if sha is blank" do
        @revision.sha = nil
        lambda { @revision.rdoc_path }.should raise_error
      end
    end

    describe "generate_rdoc" do
      before :each do
        GitRDoc::RDoc.stub!(:generate)
      end

      it "should raise an error if the RDoc has already been generated" do
        @revision.rdoc_generated_at = Time.now
        lambda { @revision.generate_rdoc }.should raise_error
      end

      it "should generate the rdoc for the repository_path into the rdoc_path" do
        GitRDoc::RDoc.should_receive(:generate).with(@revision.project.repository_path, @revision.rdoc_path, @revision.project.to_s, @revision.url)
        @revision.generate_rdoc
      end

      context "generation is successful" do
        before :each do
          GitRDoc::RDoc.stub!(:generate).and_return(true)
        end

        it "should set repository_cloned_at to the current datetime" do
          current_time = Time.now
          Time.stub!(:now).and_return(current_time)
          @revision.should_receive(:update_attribute).with(:rdoc_generated_at, current_time)
          @revision.generate_rdoc
        end
      end

      context "generation is unsuccessful" do
        before :each do
          GitRDoc::RDoc.stub!(:generate).and_return(false)
          FileUtils.stub!(:rm_rf)
        end

        it "should set error_cloning_repository to true" do
          @revision.should_receive(:update_attribute).with(:error_generating_rdoc, true)
          @revision.generate_rdoc
        end
        
        it "should delete the rdoc_path" do
          FileUtils.should_receive(:rm_rf).with(@revision.rdoc_path)
          @revision.generate_rdoc
        end
      end
    end

    describe "has_generated_rdoc?" do
      it "should be true if rdoc_generated_at has been set" do
        @revision.rdoc_generated_at = Time.now
        @revision.should have_generated_rdoc
      end

      it "should be false if rdoc_generated_at has not been set" do
        @revision.rdoc_generated_at = nil
        @revision.should_not have_generated_rdoc
      end
    end

    describe "url" do
      specify { @revision.url.should ==  "http://github.com/#{@revision.project.user_name}/#{@revision.project.name}/tree/#{@revision.sha}/" }

      it "should raise an error if sha is blank" do
        @revision.sha = nil
        lambda { @revision.url }.should raise_error
      end
    end

    describe "to_s" do
      it { @revision.to_s.should == "#{@revision.sha}"}
    end
  end
end
