ActionController::Routing::Routes.draw do |map|
  map.connect "/:user_name/:name",                    :controller => "projects",  :action => "show"
  map.connect "/:user_name/:name/status",             :controller => "projects",  :action => "status"

  map.connect "/:user_name/:name/tree/master",        :controller => "revisions", :action => "master"
  map.connect "/:user_name/:name/tree/master/status", :controller => "revisions", :action => "status"

  map.connect "/",                                    :controller => "projects",  :action => "featured",  :conditions => { :method => :get }
  map.connect "/",                                    :controller => "projects",  :action => "update",    :conditions => { :method => :post }

  map.root :controller => "projects", :action => "recent"

  def project_path(project)
    "/#{project.user_name}/#{project.name}"
  end

  def revision_path(revision)
    master_revision_path(revision.project)
  end

  def master_revision_path(project)
    "/#{project.user_name}/#{project.name}/tree/master"
  end

  def rdoc_path(revision)
    "/rdoc/#{revision.project.user_name}/#{revision.project.name}/#{revision.sha}/index.html"
  end
end
