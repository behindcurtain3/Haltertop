# == Schema Information
# Schema version: 20110531100534
#
# Table name: games
#
#  id         :integer         not null, primary key
#  black_id   :integer
#  white_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  result     :string(255)
#

class Game < ActiveRecord::Base
  DRAW = "1/2 - 1/2"
  WHITE_WIN = "1-0"
  BLACK_WIN = "0-1"

	# moves
	has_many :moves, :dependent => :destroy
	has_many :boards, :dependent => :destroy

	# User relationships
	belongs_to :black, :class_name => "User"
	belongs_to :white, :class_name => "User"

	# before creating a game run setup_game
  after_create :setup_board

	# tries a move, returns a hash that can be sent to user with error message or status of move
	def try_move(params)
		# hash contains a hash of the move information
		# two types of moves... normal & promotions
		return invalid_move_error if params[:type].nil?

		board = current_board

		return invalid_move_error if board.nil?

		move = Move.new
		move.from = Point.new(params[:fr], params[:fc])
		move.to = Point.new(params[:tr], params[:tc])

		# do_move returns a new board instance or nil
		move = board.try_move(move)

		puts move

		return invalid_move_error if move.nil?

		move.game = self
		move.notate

		#otherwise
		if !move.save!
			puts move.errors
		end

		#todo, check for endgame
		self.save
		return valid_move_result(move)
	end

	def current_board
		return Board.find(:last, :conditions => ["game_id = ?", self.id])
	end

  def winner?(user)
    if self.result.nil?
      return false
    else
      if self.result == DRAW
        return false
      else
        if self.result == WHITE_WIN && user == self.white
          return true
        elsif self.result == BLACK_WIN && user == self.black
          return true
        else
          return false
        end
      end
    end
  end

	def wrong_user_error
		error = {
			:status => "failed",
			:title => "Not Your Turn",
			:text => "It isn't your move in the current game, please wait until the opponent moves."
		}
		return error
	end

	def invalid_move_error
		error = {
			:status => "failed",
			:title => "Invalid Move",
			:text => "The move submitted was not valid, please try again."
		}
		return error
	end

	def valid_move_result(move)
		result = {
			:status => "success",
			:move => []
		}

		# add the standard move
		result[:move] << {
			:from => move.from,
			:to => move.to
		}

		# add whos turn is now is
		result[:turn] = (move.user == self.white) ? "black" : "white"

		# add a capture if necessary
		unless move.capture.nil?
			result[:capture] = {
				:at => move.capture.position
			}
		end

		# add castling
		unless move.castle.nil?
			result[:move] << {
				:from => move.castle[:from],
				:to => move.castle[:to]
			}
		end

		result[:notation] = move.notation
		return result
	end

	# takes a user and returns appropriate text to display
	def get_button_text(user)
		if self.result.nil?
			if user == self.white || user == self.black
				return "Play"
			else
				return "Watch"
			end
		else
			return self.result
		end
	end

	private

		def setup_board
			board = Board.new
			board.init
			board.game_id = self.id
			board.save
		end

end
