class Game < ActiveRecord::Base
	has_one :board, :dependent => :destroy
	
	belongs_to :black, :class_name => "User"
	belongs_to :white, :class_name => "User"
	
	before_create :create_board

	def update_board(from_r, to_r, from_c, to_c)
		board = self.board.pieces

		board.each do | hash |
			
			if hash[:row].to_i == from_r.to_i && hash[:column].to_i == from_c.to_i
				hash[:row] = to_r
				hash[:column] = to_c

				self.board.pieces = board
				self.board.save
				return true
			end
		end
		return false
	end

	private

		def create_board
			self.board = Board.new
		end
end
