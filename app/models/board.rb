class Board < ActiveRecord::Base
	serialize :pieces
	belongs_to :game

	before_create :setup_default

	private

		def setup_default
			data = [
				{ :type => "black-king", :row => "0", :column => "4" },
				{ :type => "black-queen", :row => "0", :column => "3" },
				{ :type => "black-rook", :row => "0", :column => "0" },
				{ :type => "black-rook", :row => "0", :column => "7" },
				{ :type => "black-bishop", :row => "0", :column => "2" },
				{ :type => "black-bishop", :row => "0", :column => "5" },
				{ :type => "black-knight", :row => "0", :column => "1" },
				{ :type => "black-knight", :row => "0", :column => "6" },
				{ :type => "black-pawn", :row => "1", :column => "0" },
				{ :type => "black-pawn", :row => "1", :column => "1" },
				{ :type => "black-pawn", :row => "1", :column => "2" },
				{ :type => "black-pawn", :row => "1", :column => "3" },
				{ :type => "black-pawn", :row => "1", :column => "4" },
				{ :type => "black-pawn", :row => "1", :column => "5" },
				{ :type => "black-pawn", :row => "1", :column => "6" },
				{ :type => "black-pawn", :row => "1", :column => "7" },
				{ :type => "white-king", :row => "7", :column => "4" },
				{ :type => "white-queen", :row => "7", :column => "3" },
				{ :type => "white-rook", :row => "7", :column => "0" },
				{ :type => "white-rook", :row => "7", :column => "7" },
				{ :type => "white-bishop", :row => "7", :column => "2" },
				{ :type => "white-bishop", :row => "7", :column => "5" },
				{ :type => "white-knight", :row => "7", :column => "1" },
				{ :type => "white-knight", :row => "7", :column => "6" },
				{ :type => "white-pawn", :row => "6", :column => "0" },
				{ :type => "white-pawn", :row => "6", :column => "1" },
				{ :type => "white-pawn", :row => "6", :column => "2" },
				{ :type => "white-pawn", :row => "6", :column => "3" },
				{ :type => "white-pawn", :row => "6", :column => "4" },
				{ :type => "white-pawn", :row => "6", :column => "5" },
				{ :type => "white-pawn", :row => "6", :column => "6" },
				{ :type => "white-pawn", :row => "6", :column => "7" }
			]
			self.pieces = data
		end
end
