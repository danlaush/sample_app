class UsersController < ApplicationController
	before_filter :authenticate,	:except	=> [:show, :new, :create]
	before_filter :create_new, 		:only	=> [:new, :create]
	before_filter :correct_user,	:only	=> [:edit, :update]
	before_filter :admin_user, 		:only	=> :destroy

	def index
		@title = "All users"
		@users = User.paginate(:page => params[:page], :per_page => 25)
	end

	def show
		@user = User.find_by_id(params[:id]) || User.find_by_username(params[:id])
		raise ActiveRecord::RecordNotFound if @user.nil?
		
		@microposts = @user.microposts.paginate(:page => params[:page], :per_page => 50)
		@title = "@" + @user.username
	end

	def new
		@title = "Sign up"
		@user = User.new
	end
	
	def create
		@user = User.new(params[:user])
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			@title = "Sign up"
			@user.password = ""
			@user.password_confirmation = ""
			render 'new'
		end
	end
	
	def edit
		@title = "Edit user"
	end
	
	def update
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile updated."
			redirect_to @user
		else
			@title = "Edit user"
			render 'edit'
		end
	end
	
	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User deleted"
		redirect_to users_path
	end
	
	def following
		show_follow(:following)
	end
	
	def followers
		show_follow(:followers)
	end
	
	def show_follow(action)
		@user = User.find(params[:id])
		if action == :followers then
			@title = "Followers of " + @user.name
		else
			@title = "People " + @user.name + " is following"
		end
		@users = @user.send(action).paginate(:page => params[:page])
		render 'show_follow'
	end
	
	private
	
		def create_new
			redirect_to(root_path) unless !signed_in?
		end
		
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end
		
		def admin_user
			# non-admin attempts delete
			if !current_user.admin? 
				flash[:error] = "Only administrators can do that"
				redirect_to(root_path) and return
			end
			# admin attempts delete self
			if current_user?(User.find(params[:id])) 
				flash[:error] = "Suicide is immoral"
				redirect_to(users_path) and return
			end
		end
end
