class PagesController < ApplicationController
  def home
		@title = "Home"
	end

  def news
    @title = "News"
    respond_to do |format|
      format.js # Only respond to ajax calls
    end
  end

  def getstarted
    @title = "Get Started"
    respond_to do |format|
      format.js # Only respond to ajax calls
    end
  end

  def about
    @title = "About"
    respond_to do |format|
      format.js
    end
  end
end