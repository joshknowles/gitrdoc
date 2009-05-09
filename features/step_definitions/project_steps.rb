Given /^a project on github named "(.*)"$/ do |name|
end

Given /^a project named "(.*)"$/ do |name|
  user_name_and_project_name = name.split("-")
  user_name     = user_name_and_project_name.shift
  project_name  = user_name_and_project_name.join("-")

  Project.create! do |p|
    p.user_name = user_name
    p.name      = project_name
  end
end