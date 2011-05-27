module UsersHelper

	def gravatar_for(user, options = { :size => 48 })
		if user.nil?
			gravatar_image_tag("", :alt => "No Icon", :class => "sm_round", :gravatar => options)
		else
			gravatar_image_tag(user.email.downcase, :alt => user.name,
                                            :class => "sm_round",
                                            :gravatar => options)
		end

    
	end
end