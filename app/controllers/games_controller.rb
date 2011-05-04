class GamesController < ApplicationController
  # before_filters are run before anything else is done on the controller
  # Authenticate the user
  before_filter :authenticate

  # GET /games
  def index
    @title = "Games"
    @games = Game.all
  end

  # GET /games/#{id}
  def show
    @game = Game.find(params[:id])
    @title = "Play"
  end

  # GET /games/new
  def new
    @title = "Start a New Game"
    @game = Game.new
		
  end

  # POST /games
  def create
    @game = Game.new
		@game.white_id = current_user

    # Attempt to save the new game
    if @game.save
      flash[:success] = "Game Created"
      redirect_to @game
    else
			flash[:error] = "Game could not be created"
      render :action => "new"
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

	# PUT /games/#{id}/move
	def move
		@game = Game.find(params[:id])
		if @game.update_board(params[:from_row], params[:to_row], params[:from_column], params[:to_column])
			result = { :from_column => params[:from_column],
									:to_column => params[:to_column],
									:from_row => params[:from_row],
									:to_row => params[:to_row]
									}
		else
			result = {:result => "fail"}
		end

		respond_to do |format|
				format.json { render :json => result }
		end
	end

  # Private methods
  private

end