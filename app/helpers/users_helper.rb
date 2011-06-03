module UsersHelper

	def image_for(user, classes = "sm_round", options = { :size => 48 })
		if user.nil?
			gravatar_image_tag("", :alt => "No Icon", :class => classes, :gravatar => options)
		elsif user.facebook
			image_tag user.facebook.get_picture(user.fbid), :alt => user.name, :size => "48x48" , :class => classes
		else
			gravatar_image_tag(user.email.downcase, :alt => user.name,
                                            :class => classes,
                                            :gravatar => options)
		end

	end
	
end