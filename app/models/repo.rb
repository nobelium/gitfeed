class Repo < ActiveRecord::Base
  attr_accessible :name, :owner_id
end
