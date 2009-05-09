require File.dirname(__FILE__) + '/../../spec_helper'

describe GitRDoc::RDoc do
  describe "generate" do
    before :each do
      GitRDoc::RDoc.stub!(:system)
    end

    it "should change into the src_path" do
      GitRDoc::RDoc.should_receive(:system).with do |cmd|
        cmd.should include("cd src_dir")
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should use the quite option" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include("-q")
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should set the output directory to the dest_dir" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include('--op="dest_dir"')
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should render the source inline" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include("-S")
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should set the title" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include('--title="title"')
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should link to the online version" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include('--webcvs="url"')
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should set the format to HTML" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include("--format=html")
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end

    it "should use the hanna template" do
      GitRDoc::RDoc.should_receive(:system).with do |args|
        args.should include("--template=hanna")
      end

      GitRDoc::RDoc.generate(:src_dir, :dest_dir, :title, :url)
    end
  end
end
