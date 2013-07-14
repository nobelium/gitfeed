class User < ActiveRecord::Base
  attr_accessible :fb_access_token, :fb_userid, :fb_username, :github_access_token, :github_handle
end
