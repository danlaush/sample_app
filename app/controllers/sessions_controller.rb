class SessionsController < ApplicationController
	def index
		render :new
	end

	def new
		@title = "Sign in"
	end
	
	def create
		user = User.authenticate(params[:session][:login],
								 params[:session][:password])
		if user.nil?
			# rerender new with errors
			@title = "Sign in"
			flash.now[:error] = "Invalid username/password combination"
			render :new
		else
			# sign in, redirect
			flash[:success] = "Successfully signed in"
			sign_in user
			redirect_back_or user
		end
	end
	
	def destroy
		sign_out
		redirect_to root_path
	end

end