Given /^the repository has already been cloned$/ do
  Project.last.update_attribute(:repository_cloned_at, Time.now)
  GitRDoc::Git::Repository.stub!(:revision).and_return("31e44ae0c4a9176017c896bd5c2506506e808f77")
end

Given /^it contains a tag named "([^\"]*)"$/ do |arg1|
  GitRDoc::Git::Repository.stub!(:revision).and_return("d5c1087906d31dc12b2dd65fbd0b5d1a33384ff4")
end

Given /^it doesn't contain a reference named "([^\"]*)"$/ do |reference_name|
  GitRDoc::Git::Repository.stub!(:revision).and_return(nil)
end

When /^it is done cloning the repository$/ do
  GitRDoc::Git::Repository.stub!(:clone).and_return(true)
  GitRDoc::Git::Repository.stub!(:revision).and_return("31e44ae0c4a9176017c896bd5c2506506e808f77")
  Delayed::Job.work_off
end

When /^there are errors cloning the repository$/ do
  GitRDoc::Git::Repository.stub!(:clone).and_return(false)
  Delayed::Job.work_off
end

When /^it is done updating the project$/ do
  GitRDoc::Git::Repository.stub!(:pull).and_return(true)
  GitRDoc::Git::Repository.stub!(:revision).and_return(@sha_of_latest_revision)

  GitRDoc::RDoc.stub!(:generate).and_return(true)

  Delayed::Job.work_off
end