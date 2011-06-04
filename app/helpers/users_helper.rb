module UsersHelper

	def image_for(user, classes = "sm_round", options = { :size => 48 })

		if user.nil?
			gravatar_image_tag("", :alt => "No Icon", :class => classes, :gravatar => options)
		elsif user.facebook?
			link_to user do
				image_tag user.fbgraph.get_picture(user.fbid), :alt => user.name, :size => "48x48" , :class => classes
			end
		else
			link_to user do
				gravatar_image_tag(user.email.downcase, :alt => user.name,
		                                          :class => classes,
			                                        :gravatar => options)
			end
		end

	end
	
end