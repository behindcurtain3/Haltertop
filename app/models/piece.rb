class Piece
  attr_accessor :name, :color, :position

	NOTATION_MAP = { 'king' => 'K', 'queen' => 'Q', 'rook' => 'R', 'bishop' => 'B', 'knight' => 'N', 'pawn' => 'P' }

	# Takes a piece type, column & row and returns the proper notation
	def notation
		NOTATION_MAP.each_pair do |k,v|
      if k == self.name
        return v.downcase if self.color == 'black'
        return v
      end
    end
    return "" # for pawns
	end
end
