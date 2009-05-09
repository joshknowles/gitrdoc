module Factory
  def new_project
    Project.new do |p|
      p.user_name = "user"
      p.name      = "project"
    end
  end

  def new_revision
    Revision.new do |r|
      r.project = new_project
      r.sha     = "123123123123123"
    end
  end
end