# == Schema Info
# Schema version: 20090510014855
#
# Table name: revisions
#
#  id                    :integer         not null, primary key
#  project_id            :integer
#  error_generating_rdoc :boolean
#  sha                   :string(255)
#  created_at            :datetime
#  rdoc_generated_at     :datetime
#  updated_at            :datetime

class Revision < ActiveRecord::Base
# Assocations
  belongs_to :project

# Validations
  validates_presence_of   :project_id
  validates_presence_of   :sha
  validates_uniqueness_of :sha, :scope => :project_id # SHA really should be globally unique, but I don't yet know how to handle that

# Callbacks
  after_create  :queue_generate_rdoc
  after_destroy :nullify_master_revisions
  after_destroy :delete_generated_rdoc

# Instance Methods
  def rdoc_path
    raise "sha is required to generate the rdoc_path" if sha.blank?
    File.join(project.rdoc_path, sha)
  end

  def generate_rdoc
    raise "RDoc has already been generated" if has_generated_rdoc?

    GitRDoc::Git::Repository.reset(project.repository_path, sha)

    if GitRDoc::RDoc.generate(project.repository_path, rdoc_path, project.to_s, url)
      update_attribute(:rdoc_generated_at, Time.now)
    else
      FileUtils.rm_rf(rdoc_path)
      update_attribute(:error_generating_rdoc, true)
    end
  end

  def has_generated_rdoc?
    rdoc_generated_at.present?
  end

  def url
    raise "sha is required to generate the url" if sha.blank?
    "http://github.com/#{project.user_name}/#{project.name}/tree/#{sha}/"
  end

  def to_s
    sha
  end

private

  def queue_generate_rdoc
    send_later(:generate_rdoc)
  end

  def nullify_master_revisions
    Project.update_all({ :master_revision_id => nil }, { :master_revision_id => id})
  end

  def delete_generated_rdoc
    FileUtils.rm_rf(rdoc_path)
  end
end