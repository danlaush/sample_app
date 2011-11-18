require 'spec_helper'

describe RelationshipsController do
	describe "access control" do
		it "should require signin for create" do
			post :create
			response.should redirect_to(signin_path)
		end
		
		it "should require signin for destroy" do
			post :destroy, :id => 1
			response.should redirect_to(signin_path)
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			@user1 = test_sign_in(Factory(:user))
			@user2 = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
		end
		
		it "should create a relationship using ajax" do
			lambda do
				xhr :post, :create, :relationship => { :followed_id => @user2 }
				response.should be_success
			end.should change(Relationship, :count).by(1)
		end
	end
	
	describe "DELETE 'destroy'" do
		before(:each) do
			@user1 = test_sign_in(Factory(:user))
			@user2 = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
			@user1.follow!(@user2)
			@relationship = @user1.relationships.find_by_followed_id(@user2)
		end
		
		it "should destroy a relationship" do
			lambda do
				xhr :delete, :destroy, :id => @relationship
				response.should be_success
			end.should change(Relationship, :count).by(-1)
		end
	end
end