Given /^the rdoc has been generated$/ do
  project = Project.last

  master_revision = project.revisions.create! do |r|
    r.sha               = "31e44ae0c4a9176017c896bd5c2506506e808f77"
    r.rdoc_generated_at = Time.now
  end

  project.update_attribute(:master_revision_id, master_revision.id)
end

When /^it is done generating the RDoc$/ do
  GitRDoc::RDoc.stub!(:generate).and_return(true)
  Delayed::Job.work_off
end

When /^there are errors generating the RDoc$/ do
  GitRDoc::RDoc.stub!(:generate).and_return(false)
  Delayed::Job.work_off
end

Then /^I should see the generated rdoc$/ do
  response.should have_tag("iframe")
end

Then /^I should see the generated rdoc for revision "(.+)"$/ do |sha_of_latest_revision|
  Then "I should see the generated rdoc"
  response.should contain(sha_of_latest_revision)
end