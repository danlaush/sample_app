# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
	user.name 				 "Dan Laush"
	user.email 				 "dlaush@gmail.com"
	user.password 			 "foobar"
	user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
	micropost.content		"Foo bar baz bin bash"
	micropost.association	:user
end