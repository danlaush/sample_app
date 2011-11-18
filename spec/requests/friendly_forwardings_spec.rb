require 'spec_helper'

describe "FriendlyForwardings" do
	it "should forward to the requested page after signin" do
		user = Factory(:user)
		visit edit_user_path(user)
		# automatically forwards to signin page
		fill_in :login, :with => user.username
		fill_in :password, :with => user.password
		click_button
		# automatically forwards to edit page
		response.should render_template('users/edit')
	end
end
