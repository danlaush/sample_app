require 'spec_helper'

describe PagesController do
	render_views
	
	before(:each) do
		@base_title = "Ruby on Rails Tutorial Sample App | "
	end

	describe "GET :home" do
		it "should be successful" do
			get :home
			response.should be_success
		end
		
		it "should have the right title" do
			get :home
			response.should have_selector('title', :content => @base_title + "Home")
		end
		
		describe "for signed-in users" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				mp1 = Factory(:micropost, :user => @user, :content => "Lorem ipsum")
				mp2 = Factory(:micropost, :user => @user, :content => "Sit amet, dolor")
				mp3 = Factory(:micropost, :user => @user, :content => "loli gipsup")
				@microposts = [mp1, mp2, mp3]
				
				other_user = Factory(:user, :email => Factory.next(:email))
				other_user.follow!(@user)
			end
	
			it "should have delete links for all microposts" do
				get :home
				@microposts[0..2].each do |user|
					response.should have_selector("a", :content => "delete")
				end
			end
			
			it "should have the right follow(ing||ers) counts" do
				get :home
				response.should have_selector("a", 
												:href => following_user_path(@user), 
												:content => "0 following")
				response.should have_selector("a", 
												:href => followers_user_path(@user), 
												:content => "1 follower")
			end
		end
	end

	describe "GET 'contact'" do
		it "should be successful" do
			get 'contact'
			response.should be_success
		end
		
		it "should have the right title" do
			get 'contact'
			response.should have_selector("title", :content => @base_title + "Contact")
		end
	end

	describe "GET 'about'" do
		it "should be successful" do
			get 'about'
			response.should be_success
		end
		
		it "should have the right title" do
			get 'about'
			response.should have_selector("title", :content => @base_title + "About")
		end
	end
	
	describe "GET 'help'" do
		it "should be successful" do
			get 'help'
			response.should be_success
		end
		
		it "should have the right title" do
			get 'help'
			response.should have_selector("title", :content => @base_title + "Help")
		end
	end
	
	
		
end
