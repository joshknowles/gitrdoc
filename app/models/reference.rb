# == Schema Info
# Schema version: 20090510014855
#
# Table name: references
#
#  id         :integer         not null, primary key
#  project_id :integer
#  name       :string(255)
#  sha        :string(255)
#  created_at :datetime
#  updated_at :datetime

class Reference < ActiveRecord::Base
# Assocations
  belongs_to :project

# Validations
  validates_presence_of   :project_id
  validates_presence_of   :sha
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => :project_id, :case_sensitive => false
end