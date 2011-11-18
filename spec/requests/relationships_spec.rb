require 'spec_helper'

describe "Relationships" do
	describe "follow button" do
		before(:each) do
			@user1 = Factory(:user)
			@user2 = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
		end
	
		it "should not appear for signed out users" do
			visit user_path(@user2)
			response.should_not have_selector("input", :id => "relationship_submit")
		end
		
		it "should appear for signed in users" do
			integration_sign_in(@user1)
			visit user_path(@user2)
			response.should have_selector("input", :id => "relationship_submit")
		end
	end
end
