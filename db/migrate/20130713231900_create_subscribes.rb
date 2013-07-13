class CreateSubscribes < ActiveRecord::Migration
  def change
    create_table :subscribes do |t|
      t.references :user
      t.references :repo

      t.timestamps
    end
    add_index :subscribes, :user_id
    add_index :subscribes, :repo_id
  end
end
