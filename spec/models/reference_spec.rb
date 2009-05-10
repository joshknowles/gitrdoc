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

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Reference do
  describe "Associations" do
    it { should belong_to(:project) }
  end

  describe "Validations" do
    it { should validate_presence_of(:project_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sha) }
  end
end
