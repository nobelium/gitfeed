class Subscribe < ActiveRecord::Base
  belongs_to :user
  belongs_to :repo
  attr_accessible :user_id, :repo_fullname
end
