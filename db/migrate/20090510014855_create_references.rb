class CreateReferences < ActiveRecord::Migration
  def self.up
    create_table :references, :force => true do |t|
      t.integer :project_id
      t.string  :name
      t.string  :sha
      t.timestamps
    end

    add_index :references, [:project_id, :name]
  end

  def self.down
    drop_table :references
  end
end
