class DropTableRepos < ActiveRecord::Migration
  def up
    drop_table  :repos
    
    remove_column :subscribes, :repo_id
    add_column :subscribes, :repo_fullname, :string
  end

  def down
    create_table :repos do |t|
      t.string :name
      t.integer :owner_id
      
      t.timestamps
    end

    remove_column :subscribes, :repo_fullname
    add_column :subscribes, :repo, :references
  end
end
