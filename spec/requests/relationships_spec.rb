require 'spec_helper'

describe "Relationships" do
	describe "follow button" do
		before(:each) do
			@user1 = Factory(:user)
			@user2 = Factory(:user, :email => Factory.next(:email))
		end
	
		it "should not appear for signed out users" do
			
		end
		
		it "should appear for signed in users" do
			
		end
	end
end
