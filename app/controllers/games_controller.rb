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
		@game.white = current_user

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

		result = {
			:result => "fail",
			:title => "No Update",
			:text => "The opponent has not yet made a move."
		}

    respond_to do |format|
				format.json { render :json => result }
		end
  end

	# PUT /games/#{id}/move
	def move
		@game = Game.find(params[:id])
		if current_user? @game.turn
			if @game.update_board(params[:from_row], params[:to_row], params[:from_column], params[:to_column])
			result = {
									:result => "success",
									:from_column => params[:from_column],
									:to_column => params[:to_column],
									:from_row => params[:from_row],
									:to_row => params[:to_row],
									:turn => false
									}
			else
				result = {:result => "failed",
									:title => "Hmm, something went wrong", 
									:text => "The move you tried doesn't jive with our system. We're pretty sure you can find a better one anyways."}

			end
		else
			result = {:result => "failed",
								:title => "Ah ah ah",
								:text => "Sneaky, but it isn't your move."}
		end

		respond_to do |format|
				format.json { render :json => result }
		end
	end

  # Private methods
  private

end