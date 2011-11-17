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

require 'spec_helper'

describe Micropost do
	before(:each) do
		@user = Factory(:user)
		@attr = { :content => "Test post number one" }
	end
	
	it "should create an instance with the given attributes" do
		@user.microposts.create!(@attr)
	end
	
	describe "user associations" do
		before(:each) do
			@micropost = @user.microposts.create!(@attr)
		end
		
		it "should have a user attribute" do
			@micropost.should respond_to(:user)
		end
		
		it "should have the right associated user" do
			@micropost.user_id.should == @user.id
			@micropost.user.should == @user
		end
		
	end
	
	describe "validations" do
		it "should require a user id" do
			Micropost.new(@attr).should_not be_valid
		end
		
		it "should require nonblank content" do
			@user.microposts.build(:content => "    ").should_not be_valid
		end
		
		it "should reject long content" do
			@user.microposts.build(:content => "a" * 141).should_not be_valid
		end
	end
	
	describe "from_users_followed_by" do
		before(:each) do
			@user2 = Factory(:user, :email => Factory.next(:email))
			@user3 = Factory(:user, :email => Factory.next(:email))
			
			@user_post = @user.microposts.create!(:content => "foo")
			@user2_post = @user2.microposts.create!(:content => "bar")
			@user3_post = @user3.microposts.create!(:content => "baz")
			
			@user.follow!(@user2)
		end
		
		it "should have a from_users_followed_by class method" do
			Micropost.should respond_to(:from_users_followed_by)
		end
		
		it "should include the user's own microposts" do
			Micropost.from_users_followed_by(@user).should include(@user_post)
		end
		
		it "should include the user's followed users' microposts" do
			Micropost.from_users_followed_by(@user).should include(@user2_post)
		end
		
		it "should not include unfollowed users' microposts" do
			Micropost.from_users_followed_by(@user).should_not include(@user3_post)
		end
	end
end
