# == Schema Information
# Schema version: 20110527073557
#
# Table name: pieces
#
#  id      :integer         not null, primary key
#  name    :string(255)
#  color   :string(255)
#  col     :integer
#  row     :integer
#  active  :boolean         default(TRUE)
#  game_id :integer
#

class Piece < ActiveRecord::Base
  belongs_to :game

  attr_accessible :name, :color, :col, :row, :active, :game

	NOTATION_MAP = { 'king' => 'K', 'queen' => 'Q', 'rook' => 'R', 'bishop' => 'B', 'knight' => 'N' }

	# Takes a piece type, column & row and returns the proper notation
	def notation
		NOTATION_MAP.each_pair do |k,v|
      if k == self.name
        return v.downcase if self.color == 'black'
        return v
      end
    end
    return ""
	end
end
