class Game < ActiveRecord::Base
	# setup class relationships, board is dependent on a game
	has_one :board, :dependent => :destroy

	# moves
	has_many :moves, :dependent => :destroy

	# User relationships
	belongs_to :black, :class_name => "User"
	belongs_to :white, :class_name => "User"
	belongs_to :turn, :class_name => "User"

	# before creating a game run setup_game
	before_create :setup_game

	def update_board(from_r, to_r, from_c, to_c)
		board = self.board.pieces

		board.each do | hash |
			
			if hash[:row].to_i == from_r.to_i && hash[:column].to_i == from_c.to_i
				hash[:row] = to_r
				hash[:column] = to_c

        # Store the move
        m = Move.new
        m.from_column = from_c
        m.to_column = to_c
        m.from_row = from_r
        m.to_row = to_r
        m.game = self
        m.user = self.turn
        m.save

        # Update the board
				self.board.pieces = board
				self.board.save
				swap_turns
				return true
			end
		end
		return false
	end

	def whos_turn
		if self.turn == self.white
			return "white"
		else
			return "black"
		end
	end

	private

		def setup_game
			create_board

			unless self.white.nil?
				self.turn = self.white
			end
		end

		def create_board
			self.board = Board.create
		end

		def swap_turns
			if self.turn == self.white
				self.turn = self.black
			else
				self.turn = self.white
			end
			self.save
		end
end