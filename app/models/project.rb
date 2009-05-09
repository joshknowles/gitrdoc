# == Schema Info
# Schema version: 20090509201408
#
# Table name: projects
#
#  id                       :integer         not null, primary key
#  master_revision_id       :integer
#  error_cloning_repository :boolean
#  name                     :string(255)
#  user_name                :string(255)
#  created_at               :datetime
#  repository_cloned_at     :datetime
#  updated_at               :datetime

class Project < ActiveRecord::Base
# Associations
  has_many    :revisions, :dependent => :destroy
  belongs_to  :master_revision, :class_name => "Revision"

# Validations
  validates_presence_of   :user_name
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => :user_name, :case_sensitive => false

# Callbacks
  after_create  :queue_clone_repository
  after_destroy :delete_cloned_repository

# Accessibility
  attr_accessible :user_name, :name

# Instance Methods
  def repository_url
    raise "user_name is required to generate the repository_url" if user_name.blank?
    raise "name is required to generate the repository_url"      if name.blank?

    "git://github.com/#{user_name}/#{name}.git"
  end

  def repository_path
    raise "user_name is required to generate the repository_path" if user_name.blank?
    raise "name is required to generate the repository_path"      if name.blank?

    File.join(GitRDoc.repository_root, user_name, name)
  end

  def rdoc_path
    raise "user_name is required to generate the rdoc_path" if user_name.blank?
    raise "name is required to generate the rdoc_path"      if name.blank?

    File.join(GitRDoc.rdoc_root, user_name, name)
  end

  def clone_repository
    raise "repository has already been cloned" if has_cloned_repository?

    if GitRDoc::Git::Repository.clone(repository_url, repository_path)
      update_attribute(:repository_cloned_at, Time.now)
    else
      update_attribute(:error_cloning_repository, true)
    end
  end

  def has_cloned_repository?
    repository_cloned_at.present?
  end

  def master_revision
    raise "repository hasn't been cloned" unless has_cloned_repository?

    if master_revision_id.present?
      revisions.find(master_revision_id)
    else
      returning revisions.find_or_create_by_sha(GitRDoc::Git::Repository.revision(repository_path)) do |master_revision|
        update_attribute(:master_revision_id, master_revision.id)
      end
    end
  end

  def pull_repository_and_generate_rdoc
    raise "repository hasn't been cloned" unless has_cloned_repository?

    if GitRDoc::Git::Repository.pull(repository_path)
      revision = revisions.find_or_initialize_by_sha(GitRDoc::Git::Repository.revision(repository_path))
      revision.generate_rdoc unless revision.has_generated_rdoc?
      update_attribute(:master_revision_id, revision.id)
    else
    end
  end

  def url
    raise "user_name is required to generate the url" if user_name.blank?
    raise "name is required to generate the url"      if name.blank?

    "http://github.com/#{user_name}/#{name}/tree/master"
  end

  def to_s
    user_name + "-" + name
  end

private

  def queue_clone_repository
    send_later(:clone_repository)
  end

  def delete_cloned_repository
    FileUtils.rm_rf(repository_path)
  end
end