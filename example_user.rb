class User
  def shuffStr(str)
  	puts str
  	a = str.split('')
  	puts a.to_s
  	b = str.split('').shuffle
  	puts b.to_s
  	c = str.split('').shuffle.join
  	puts c
  	return c
  end
end