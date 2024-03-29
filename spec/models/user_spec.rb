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

require 'spec_helper'

describe User do

	before(:each) do
		@attr = {
			:name => "Example User",
			:email => "user@example.com",
			:username => "ExampleUser",
			:password => "foobar",
			:password_confirmation => "foobar"
		}
	end
	
	it "should create a new instance given valid attributes" do
		User.create!(@attr)
	end
	
	it "should require a username" do
		no_username = User.new(@attr.merge(:username => ""))
		no_username.should_not be_valid
	end
	
	it "should reject usernames that are too long" do
		long_name = "a" * 31
		long_name_user = User.new(@attr.merge(:username => long_name))
		long_name_user.should_not be_valid
	end
	
	it "should reject duplicate usernames" do
		# First actually put a user in the db to compare to
		# Change test email so emails unique
		User.create!(@attr.merge(:email => "anotherEmail@example.com"))
		user_with_dupe_username = User.new(@attr)
		user_with_dupe_username.should_not be_valid
	end
	
	it "should accept valid usernames" do
		usernames = %w[DanLaush DANLAUSH danlaush123 dan_laush -xXDan_LaushXx-]
		usernames.each do |username|
			valid_username_user = User.new(@attr.merge(:username => username))
			valid_username_user.should be_valid
		end
	end
	
	it "should reject invalid usernames" do
		usernames = ["%danlaush%","Dan Laush","; --mysql DROP * from BobbyTables"]
		usernames.each do |username|
			invalid_username_user = User.new(@attr.merge(:username => username))
			invalid_username_user.should_not be_valid
		end
	end
	
	it "should not require a name" do
		no_email = User.new(@attr.merge(:name => ""))
		no_email.should be_valid
	end
	
	it "should reject names that are too long" do
		long_name = "a" * 51
		long_name_user = User.new(@attr.merge(:name => long_name))
		long_name_user.should_not be_valid
	end
	
	it "should require an email address" do
		no_email = User.new(@attr.merge(:email => ""))
		no_email.should_not be_valid
	end
	
	it "should accept valid email addresses" do
		addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
		addresses.each do |address|
			valid_email_user = User.new(@attr.merge(:email => address))
			valid_email_user.should be_valid
		end
	end
	
	it "should reject invalid email addresses" do
		addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
		addresses.each do |address|
			valid_email_user = User.new(@attr.merge(:email => address))
			valid_email_user.should_not be_valid
		end
	end
	
	it "should reject duplicate emails" do
		# First actually put a user in the db to compare to
		# Change test username so usernames unique
		User.create!(@attr.merge(:username => "anotherUser"))
		user_with_dupe_email = User.new(@attr)
		user_with_dupe_email.should_not be_valid
	end
	
	describe "password validations" do
		it "should require a password" do
			no_pass = User.new(@attr.merge(:password => "", :password_confirmation => ""))
			no_pass.should_not be_valid
		end
		
		it "should require an identical password confirmation" do
			wrong_conf = User.new(@attr.merge(:password_confirmation => ""))
			wrong_conf.should_not be_valid
		end
		
		it "should reject passwords under 6 characters" do
			pass = "a" * 5
			short_pass = User.new(@attr.merge(:password => pass, :password_confirmation => pass))
			short_pass.should_not be_valid
		end
		
		it "should reject passwords over 50 characters" do
			pass = "a" * 51
			long_pass = User.new(@attr.merge(:password => pass, :password_confirmation => pass))
			long_pass.should_not be_valid
		end
	end
	
	describe "password encryption" do

		before(:each) do
			@user = User.create!(@attr)
		end

		it "should have an encrypted password attribute" do
			@user.should respond_to(:encrypted_password)
		end
		
		it "should set the encrypted password" do
			@user.encrypted_password.should_not be_blank
		end
		
		describe "has_password? method" do
			it "should be true if the passwords match" do
				@user.has_password?(@attr[:password]).should be_true
			end
			
			it "should be false if the passwords don't match" do
				@user.has_password?("invalid").should be_false
			end
		end
		
		describe "authenticate method" do
			it "should return nil on username/pass mismatch" do
				wrong_pass = User.authenticate(@attr[:username], "wrongpass")
				wrong_pass.should be_nil
			end
			
			it "should return nil on username not found" do
				no_user = User.authenticate("wrongCom", @attr[:password])
				no_user.should be_nil
			end
			
			it "should return User on correct email/pass" do
				success = User.authenticate(@attr[:username], @attr[:password])
				success.should == @user
			end
		end
	end
	
	describe "admin attribute" do
		before(:each) do
			@user = User.create(@attr)
		end
		
		it "should respond to admin" do
			@user.should respond_to(:admin)
		end
		
		it "should not be admin by default" do
			@user.should_not be_admin
		end
		
		it "should be convertible to admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
	end
	
	describe "micropost associations" do
		before(:each) do
			@user = User.create!(@attr)
			@mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
			@mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
		end
		
		it "should have a microposts attribute" do
			@user.should respond_to(:microposts)
		end
		
		it "should have the right microposts in the right order" do
			@user.microposts.should == [@mp2, @mp1]
		end
		
		it "should destroy associated microposts" do
			@user.destroy
			[@mp1, @mp2].each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
			end
		end
		
		describe "status feed" do
			it "should have a feed" do
				@user.should respond_to(:feed)
			end
			
			it "should include the user's microposts" do
				@user.feed.should include(@mp1)
				@user.feed.should include(@mp2)
			end
			
			it "should not include a different user's microposts" do
				mp3 = Factory(  :micropost, 
								:user => Factory(:user, 
												 :username => Factory.next(:username), 
												 :email => Factory.next(:email)))
				@user.feed.should_not include(mp3)
			end
			
			it "should include the user's followed users' microposts" do
				followed = Factory( :user, 
									:username => Factory.next(:username), 
									:email => Factory.next(:email))
				mp3 = Factory(:micropost, :user => followed)
				@user.follow!(followed)
				@user.feed.should include(mp3)
			end
		end
	end
	
	describe "relationships" do
		before(:each) do
			@user = User.create!(@attr)
			@followed = Factory(:user)
		end
		
		it "should have a relationships method" do
			@user.should respond_to(:relationships)
		end
		
		it "should have a following method" do
			@user.should respond_to(:following)
		end
		
		it "should have a following? method" do
			@user.should respond_to(:following?)
		end
		
		it "should have a follow! method" do
			@user.should respond_to(:follow!)
		end
		
		it "should follower another user" do
			@user.follow!(@followed)
			@user.should be_following(@followed)
		end
		
		it "should include the followed user in the following array" do
			@user.follow!(@followed)
			@user.following.should include(@followed)
		end
		
		it "should have an unfollow! method" do
			@user.should respond_to(:unfollow!)
		end
		
		it "should unfollow a user" do
			@user.follow!(@followed)
			@user.unfollow!(@followed)
			@user.should_not be_following(@followed)
		end
		
		it "should have a reverse_relationships method" do
			@user.should respond_to(:reverse_relationships)
		end
		
		it "should have a followers method" do
			@user.should respond_to(:followers)
		end
		
		it "should include the follower in the followers array" do
			@user.follow!(@followed)
			@followed.followers.should include(@user)
		end
	end
end

