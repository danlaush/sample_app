# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name = User.new(@attr.merge(:name => ""))
    no_name.should_not be_valid
  end
  
  it "should require an email address" do
    no_email = User.new(@attr.merge(:email => ""))
    no_email.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
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
    User.create!(@attr)
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
    
    it "should reject passwords over 30 characters" do
      pass = "a" * 31
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
      it "should return nil on email/pass mismatch" do
        wrong_pass = User.authenticate(@attr[:email], "wrongpass")
        wrong_pass.should be_nil
      end
      
      it "should return nil on email not found" do
        no_user = User.authenticate("wrong@bad.com", @attr[:password])
        no_user.should be_nil
      end
      
      it "should return User on correct email/pass" do
        success = User.authenticate(@attr[:email], @attr[:password])
        success.should == @user
      end
    end
  end
end