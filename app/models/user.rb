# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#  username           :string(255)
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#

require 'digest'

class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :username, :name, :email, :password, :password_confirmation
	
	has_many :microposts, 
				:dependent 		=> :destroy
	has_many :relationships, 
				:foreign_key 	=> "follower_id", 
				:dependent 		=> :destroy
	has_many :following, 
				:through		=> :relationships, 
				:source 		=> :followed
	has_many :reverse_relationships,
				:foreign_key 	=> "followed_id",
				:class_name		=> "Relationship",
				:dependent 		=> :destroy
	has_many :followers,
				:through		=> :reverse_relationships,
				:source			=> :follower
	
	username_regex = /^[-_\.0-9a-zA-Z]+$/i
	EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates 	:username,	 	
							:presence 		=> true,
				 			:length			=> { :within => 6..30 },
							:format			=> { :with => username_regex },
							:uniqueness		=> { :case_sensitive => false }
	validates 	:name,	 	
				 			:length			=> { :maximum => 30 }
	validates 	:email, 	
							:presence		=> true,
							:format			=> { :with => EMAIL_REGEX },
							:uniqueness		=> { :case_sensitive => false }
	validates 	:password, 	
							:presence 		=> true,
							:confirmation	=> true,
							:length			=> { :within => 6..50 }
							
	before_save :encrypt_password
	
	def has_password?(submitted)
		self.encrypted_password == encrypt(submitted)
	end
	
	def self.authenticate(login, submitted_password)
		if login =~ EMAIL_REGEX
			user = find_by_email(login)
		else 
			user = find_by_username(login)
		end
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
	end
	
	def self.authenticate_with_salt(id, cookie_salt)
		user = find_by_id(id)
		(user && user.salt == cookie_salt) ? user : nil
	end
	
	def following?(followed)
		relationships.find_by_followed_id(followed)
	end
	
	def follow!(followed)
		relationships.create!(:followed_id => followed.id)
	end
	
	def unfollow!(followed)
		relationships.find_by_followed_id(followed).destroy
	end
	
	def feed
		Micropost.from_users_followed_by(self)
	end
	
	private
	
		def encrypt_password
			self.salt = make_salt unless has_password?(self.password)
			self.encrypted_password = encrypt(self.password)
		end
		
		def encrypt(string)
			secure_hash("#{self.salt}--#{string}")
		end
		
		def make_salt
			secure_hash("#{Time.now.utc}--#{self.password}")
		end
		
		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end
end

