ActionController::Routing::Routes.draw do |map|
  map.connect "/:user_name/:name",        :controller => "projects",  :action => "show"
  map.connect "/:user_name/:name/status", :controller => "projects",  :action => "status"

  map.connect "/:user_name/:project_name/tree/:name",         :controller => "revisions", :action => "show",    :requirements => { :name => /[^\/]+/ }
  map.connect "/:user_name/:project_name/tree/:name/status",  :controller => "revisions", :action => "status",  :requirements => { :name => /[^\/]+/ }

  map.connect "/",  :controller => "projects",  :action => "featured",  :conditions => { :method => :get }
  map.connect "/",  :controller => "projects",  :action => "update",    :conditions => { :method => :post }

  map.root :controller => "projects", :action => "recent"

  def project_path(project)
    "/#{project.user_name}/#{project.name}"
  end

  def revision_path(project, reference = "master")
    "/#{project.user_name}/#{project.name}/tree/#{reference}"
  end

  def rdoc_path(revision)
    "/rdoc/#{revision.project.user_name}/#{revision.project.name}/#{revision.sha}/index.html"
  end
end
