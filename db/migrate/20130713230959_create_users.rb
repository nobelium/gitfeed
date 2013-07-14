class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :github_handle
      t.string :fb_username
      t.string :fb_userid
      t.string :github_access_token
      t.string :fb_access_token

      t.timestamps
    end
  end
end
