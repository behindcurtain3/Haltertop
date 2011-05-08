class BoardsController < ApplicationController
  # before_filters are run before anything else is done on the controller
  # Authenticate the user
  before_filter :authenticate

  # GET /games/#{id}
  def show
    @game = Game.find(params[:id])

		respond_to do |format|
			format.json { render :json => @game.board.pieces }
		end
  end

  # PUT /games/#{id}
  def update
    @game = Game.find(params[:id])

    # Attempt to update attributes
    #if @user.update_attributes(params[:user])
    #  flash[:success] = "Settings saved."
    #else
      # if not successful re-render the edit page
      #@title = "Edit"
      #render :action => "edit"
    #end
  end

  # Private methods
  private

end