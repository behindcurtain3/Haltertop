class PagesController < ApplicationController
  def home
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