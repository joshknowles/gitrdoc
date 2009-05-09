class ProjectsController < ApplicationController
# Filters
  before_filter :find_or_initialize_project, :only => [ :show, :status ]

# Actions
  def show
    if @project.has_cloned_repository?
      redirect_to master_revision_path(@project)
    elsif @project.save
      render "status", :layout => "status"
    end
  end

  def status
    raise ActiveRecord::RecordNotFound if @project.new_record?

    respond_to do |format|
      format.html { render "status", :layout => "status" }
      format.js
    end
  end

  def update
    if params[:payload].present?
      payload     = JSON.parse(params[:payload])
      repository  = payload["repository"]
      project     = Project.find_by_user_name_and_name(repository["owner"]["name"], repository["name"])

      project.send_later(:pull_repository_and_generate_rdoc)
    end

    head :ok
  end

private

  def find_or_initialize_project
    @project = Project.find_or_initialize_by_user_name_and_name(params[:user_name], params[:name])
  end
end