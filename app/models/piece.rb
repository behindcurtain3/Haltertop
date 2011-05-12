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

	NOTATION_MAP = { 'king' => 'K', 'queen' => 'Q', 'rook' => 'R', 'bishop' => 'B', 'knight' => 'N' }

	# Takes a piece type, column & row and returns the proper notation
	def notation
		NOTATION_MAP.each do |type|
			if type.key == self.name
				return type.value
			end
		end
	end
end
