class User < ActiveRecord::Base
  attr_accessible :fb_access_token, :fb_user_id, :fb_user_name, :github_access_token, :github_user_id, :github_user_name
end
