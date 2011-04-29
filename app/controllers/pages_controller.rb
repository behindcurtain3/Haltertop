class PagesController < ApplicationController
  def home
		@title = "Home"
	end

  def news
    @title = "News"
  end

  def getstarted
    @title = "Get Started"
  end

  def about
    @title = "About"
  end
end