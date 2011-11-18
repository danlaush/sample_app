# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_microposts_on_user_id_and_created_at  (user_id,created_at)
#

class Micropost < ActiveRecord::Base
	attr_accessible :content
	
	belongs_to :user
	
	validates :content, :presence => true, :length => { :maximum => 140 }
	validates :user_id, :presence => true
	
	default_scope :order => 'microposts.created_at DESC'
	
	# scope instead of class method allows pagination at a db level
	scope :from_users_followed_by, lambda { |user| followed_by(user) }
	
	private
	
		def self.followed_by(user)
			following_ids = %(SELECT followed_id FROM relationships 
							WHERE follower_id = :user_id)
			where("user_id IN (#{following_ids}) OR user_id = :user_id", :user_id => user)
		end
end

