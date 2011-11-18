namespace :db do
	desc "Fill database with sample data"
	task :populate => :environment do
		Rake::Task['db:reset'].invoke
		make_users
		make_microposts
		make_relationships
	end
end

def make_users
	admin = User.create!(:username => "adminUser",
						 :name => "Admin User",
						 :email => "admin@ex.org",
						 :password => "foobar",
						 :password_confirmation => "foobar")
	admin.toggle!(:admin)
	99.times do |n|
		name		= Faker::Name.name
		username	= name.gsub(/\W+/, '')
		email		= "example-#{n+1}@example.org"
		password	= "password"
		User.create!(:username => username,
					 :name => name,
					 :email => email,
					 :password => password,
					 :password_confirmation => password)
	end
end

def make_microposts
	50.times do
		User.all(:limit => 6).each do |user|
			user.microposts.create!(:content => Faker::Lorem.sentence(5))
		end
	end
end

def make_relationships
	users = User.all
	user = users.first
	following = users[1..50]
	followers = users[3..40]
	following.each { |followed| user.follow!(followed) }
	followers.each { |follower| follower.follow!(user) }
end