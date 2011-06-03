class PagesController < ApplicationController
  def home
		@title = "Home"
		@user = User.new
		@friends = []
		if signed_in? && facebook_signed
			fb_friends = facebook_signed.get_connections("me", "friends")
			ids = []
			fb_friends.each do | friend |
				ids << friend['id']
			end

			# only query if ids have something
			if ids.length > 0
				@friends = User.find(:all, :limit => 8, :order => "random()", :conditions => ["fbid IN (?)", ids])
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