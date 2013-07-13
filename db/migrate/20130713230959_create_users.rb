class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :github_user_name
      t.string :fb_user_name
      t.string :github_user_id
      t.string :fb_user_id
      t.string :github_access_token
      t.string :fb_access_token

      t.timestamps
    end
  end
end
