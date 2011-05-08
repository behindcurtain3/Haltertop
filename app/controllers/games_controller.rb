require 'pusher'

Pusher.app_id = '5414'
Pusher.key = 'e0b03bb1cb7d458de516'
Pusher.secret = '8a8e8d9612f7391352e8'

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
		if params[:game][:turn] == "black"
			@game.black = current_user
		else 
			@game.white = current_user
		end

    # Attempt to save the new game
    if @game.save
      gflash :success => "Game Created"
      redirect_to @game
    else
			gflash :error => "Game could not be created"
      render :action => "new"
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
									:turn => @game.whos_turn
									}
				# Use Pusher to send the move to all clients listening to the game
				Pusher[@game.id.to_s].trigger('move', result)
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