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
    unless params[:game].nil?
      if params[:game][:turn] == "black"
        @game.black = current_user
      else
        @game.white = current_user
      end
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
			result = @game.update_board(params[:from_row].to_i, params[:to_row].to_i, params[:from_column].to_i, params[:to_column].to_i)
				
				# Use Pusher to send the move to all clients listening to the game
        if result[:status] == "success"
  				Pusher[@game.id.to_s].trigger('move', result)
        end
		else
			result = {
        :result => "failed",
				:title => "Ah ah ah",
        :text => "Sneaky, but it isn't your move."
      }
		end

		respond_to do |format|
				format.json { render :json => result }
		end
	end

  # GET /games/#{id}/pieces
  def pieces
    @pieces = Piece.find(:all, :conditions => ['game_id = ? AND active = ?', params[:id], true], :select => [ :name, :color, :column, :row ])

		respond_to do |format|
			format.json { render :json => @pieces }
		end
  end

  # Private methods
  private

end