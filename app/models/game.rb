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
		puts "Trying a move:"
		puts board.nil?
		puts current_board.nil?
		return invalid_move_error if board.nil?

		if params[:type] == "standard"
			return invalid_move_error if waiting_for_promotion?

			move = Move.new
			move.from = Point.new(params[:fr], params[:fc])
			move.to = Point.new(params[:tr], params[:tc])

			# do_move returns a new board instance or nil
			move = board.try_move(move)

			return invalid_move_error if move.nil?

			move.game = self
			move.notate

			#otherwise
			if !move.save!
				puts move.errors
			end
			
			self.save
			if move.promoted.nil?
				return valid_move_result(move)
			else
				result = {
					:status => "success",
					:promotion => (board.turn == "w") ? "black" : "white"
				}
				return result
			end
		elsif params[:type] == "promotion"
			return invalid_move_error unless waiting_for_promotion?

			move = last_move
			return invalid_move_error if move.nil?

			return invalid_move_error if not ["queen","rook","bishop","knight"].include?(params[:to])

			board.set_piece_type(move.promoted, params[:to])
			move = board.update_after_move(move)
			board.save

			# re-notate the move
			move.piece = board.get_pieces.to_a.find { |p| p.position == move.promoted }
			move.notate
			move.save

			result = valid_move_result(move)
			result[:set] = {
				:position => move.to,
				:type => params[:to]
			}
			return result
		else
			puts "invalid type"
			return invalid_move_error
		end

	end

	def current_board
		return Board.find(:last, :conditions => ["game_id = ?", self.id])
	end

	def last_move
		return Move.find(:last, :conditions => ["game_id = ?", self.id])
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

	def waiting_for_promotion?
		move = last_move
		return false if move.nil?
		return false if move.promoted.nil?

		board = current_board
		piece = board.get_pieces.to_a.find { |p| p.name == "pawn" && p.position.row == 7 && p.color == "black" }
		return true unless piece.nil?
		piece = board.get_pieces.to_a.find { |p| p.name == "pawn" && p.position.row == 0 && p.color == "white" }
		return true unless piece.nil?
		return false
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

	def whos_turn
		turn = current_board.whos_turn

		if waiting_for_promotion?
			if turn == self.white
				return self.black
			else
				return self.white
			end
		else
			return turn
		end

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
