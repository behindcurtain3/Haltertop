class PagesController < ApplicationController
  def home
		@title = "Home"
		@user = User.new
		@friends = []
		if signed_in? && facebook_signed
			@fb_friends = facebook_signed.get_connections("me", "friends")
			
			@fb_friends.each do | friend |
				user = User.find_by_fbid(friend['id'])
				if user
					@friends.push(user)
				end
			end
		end
	end

  def about
    @title = "About"
  end

  def contact
    @title = "Contact"
  end

	def play
		@title = "Play"
	end
end