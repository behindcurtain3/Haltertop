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
    unless params[:game].nil?
			# if params[:game] is set the user created a custom game
			@game = Game.new

      if params[:game][:turn] == "black"
        @game.black = current_user
      else
        @game.white = current_user
      end

    else
			# else the user hit "play now", we want to find a game that is
			# lacking a player, if none exists then create a new game
			@game = current_user.find_match
    end

    # Attempt to save the new game
    if @game.save
      gflash :success => "Enjoy the game!"
      redirect_to @game
    else
			gflash :error => "Our referee, Bongo could not create a new game."
      render :action => "new"
    end
  end

	# PUT /games/#{id}/move
	def move
		@game = Game.find(params[:id])
		if current_user? @game.turn
			result = @game.move(params[:from_row].to_i, params[:to_row].to_i, params[:from_column].to_i, params[:to_column].to_i)
				
				# Use Pusher to send the move to all clients listening to the game
        if result[:status] == "success"
  				Pusher[@game.id.to_s].trigger('move', result)
        end
		else
			result = {
        :status => "failed",
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
    @pieces = Piece.find(:all, :conditions => ['game_id = ? AND active = ?', params[:id].to_i, true], :select => [ :name, :color, :column, :row ])

		respond_to do |format|
			format.json { render :json => @pieces }
		end
  end

  # Private methods
  private

end