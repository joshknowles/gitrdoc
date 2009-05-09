When /^GitHub sends a post commit message for revision "(.+)"$/ do |sha_of_latest_revision|
  @sha_of_latest_revision = sha_of_latest_revision

  project = Project.last
  payload = { :repository => { :name => project.name, :owner => { :name => project.user_name } } }

  post "/", :payload => JSON.generate(payload)
end