class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string    :user_name
      t.string    :name
      t.boolean   :error_cloning_repository
      t.datetime  :repository_cloned_at
      t.integer   :master_revision_id
      t.timestamps
    end

    add_index :projects, [:user_name, :name]
  end

  def self.down
    drop_table :projects
  end
end