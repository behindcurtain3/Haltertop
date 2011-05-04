class Game < ActiveRecord::Base
	# setup class relationships, board is dependent on a game
	has_one :board, :dependent => :destroy

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

				self.board.pieces = board
				self.board.save
				swap_turns
				return true
			end
		end
		return false
	end

	private

		def setup_game
			create_board

			self.turn = self.white
		end

		def create_board
			self.board = Board.new
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
