require 'spec_helper'

describe PagesController do
	render_views
	
	before(:each) do
		@base_title = "Ruby on Rails Tutorial Sample App | "
	end

	describe "GET 'home'" do
		it "should be successful" do
			get 'home'
			response.should be_success
		end
		
		it "should have the right title" do
			get 'home'
			response.should have_selector('title', :content => @base_title + "Home")
		end
		
		describe "for signed-in users" do
			before(:each) do
				@user = Factory(:user)
				mp1 = Factory(:micropost, :user => @user, :content => "Lorem ipsum")
				mp2 = Factory(:micropost, :user => @user, :content => "Sit amet, dolor")
				mp3 = Factory(:micropost, :user => @user, :content => "loli gipsup")
				@microposts = [mp1, mp2, mp3]
			#	@microposts = [@user, second, third]
			#	30.times do
			#		@microposts << Factory(:micropost, :user => @user, :content => "Lorem ipsum")
			#	end
			end
	
			it "should have delete links for all microposts" do
				test_sign_in(@user)
				get 'home'
				@microposts[0..2].each do |user|
					response.should have_selector("a", :content => "delete")
				end
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
