module ApplicationHelper

<<<<<<< HEAD
  # Returns logo image tag
  def logo
  	image_tag("logo.png", :alt => "Sample App Logo", :class => "round")
=======
  # Return the logo image
  def logo
    image_tag("logo.png", :alt => "Sample App Logo", :class => "round")
>>>>>>> modeling-users
  end

  # Return a title on a per-page basis.
  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
end
