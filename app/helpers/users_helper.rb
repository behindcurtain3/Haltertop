module UsersHelper

	def image_for(user, options = { :size => 48 })
		if user.nil?
			gravatar_image_tag("", :alt => "No Icon", :class => "sm_round", :gravatar => options)
		elsif user.facebook
			image_tag user.facebook.get_picture(user.fbid), :alt => user.name, :size => "48x48" , :class => "sm_round"
		else
			gravatar_image_tag(user.email.downcase, :alt => user.name,
                                            :class => "sm_round",
                                            :gravatar => options)
		end

	end

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