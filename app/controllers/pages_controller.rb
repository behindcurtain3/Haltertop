class PagesController < ApplicationController
  def home
		if signed_in?
			redirect_to current_user
		end

		@title = "Home"
		@user = User.new
		
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