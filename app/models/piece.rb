# == Schema Information
# Schema version: 20110509040216
#
# Table name: pieces
#
#  id      :integer         not null, primary key
#  name    :string(255)
#  color   :string(255)
#  column  :integer
#  row     :integer
#  active  :boolean         default(TRUE)
#  game_id :integer
#

class Piece < ActiveRecord::Base
  belongs_to :game

  attr_accessible :name, :color, :column, :row, :active, :game

	# moves returns an array of [x,y] coordinates on the board that piece can move
	# to based off its current position. *** Does not care about pieces blocking
	# its path etc... it assumes an empty board
	def moves
		move_list = []
		case self.name
		when "king"
			# king can move 1 space each direction
			[[-1,-1],[0,-1],[1,-1], [-1,0],[1,0] ,[-1,1],[0,1],[1,1]].each do | move |
				if valid_index?(column + move[0]) && valid_index?(row + move[1])
					move_list << [column + move[0], row + move[1]] # push onto array
				end
			end
		when "queen"
		when "rook"
		when "bishop"
		when "knight"
		when "pawn"
			# changes direction based on color
		end

	end

	private
		def valid_index?(i)
			return (i >= 0 && i <= 7)
		end
end
