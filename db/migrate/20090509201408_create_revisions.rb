class CreateRevisions < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
      t.integer   :project_id
      t.string    :sha
      t.boolean   :error_generating_rdoc
      t.datetime  :rdoc_generated_at
      t.timestamps
    end

    add_index :revisions, [:project_id, :sha]
  end

  def self.down
    drop_table :revisions
  end
end
