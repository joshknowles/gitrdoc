class RevisionsController < ApplicationController
# Filters
  before_filter :find_project
  before_filter :initialize_revision

# Actions
  def show
    if @revision.present? && @revision.has_generated_rdoc?
      render "show"
    else
      render "status", :layout => "status"
    end
  end

  def status
    respond_to do |format|
      format.html { render "status", :layout => "status" }
      format.js
    end
  end

private

  def find_project
    @project = Project.find_by_user_name_and_name(params[:user_name], params[:project_name])

    raise ActiveRecord::RecordNotFound if @project.nil?
  end

  def initialize_revision
    @revision = @project.revision(params[:name])
  end
end