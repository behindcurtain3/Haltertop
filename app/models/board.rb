class Board < ActiveRecord::Base
	# Serialize will make our hash retrievable from the db
	serialize :pieces

	# Each board belongs to a game
	belongs_to :game

	# Before a new record is created set it up with the default config
	before_create :setup_default

	private

		def setup_default
			data = [
				{ :color => "black", :type => "king", :row => "0", :column => "4" },
				{ :color => "black", :type => "queen", :row => "0", :column => "3" },
				{ :color => "black", :type => "rook", :row => "0", :column => "0" },
				{ :color => "black", :type => "rook", :row => "0", :column => "7" },
				{ :color => "black", :type => "bishop", :row => "0", :column => "2" },
				{ :color => "black", :type => "bishop", :row => "0", :column => "5" },
				{ :color => "black", :type => "knight", :row => "0", :column => "1" },
				{ :color => "black", :type => "knight", :row => "0", :column => "6" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "0" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "1" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "2" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "3" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "4" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "5" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "6" },
				{ :color => "black", :type => "pawn", :row => "1", :column => "7" },
				{ :color => "white", :type => "king", :row => "7", :column => "4" },
				{ :color => "white", :type => "queen", :row => "7", :column => "3" },
				{ :color => "white", :type => "rook", :row => "7", :column => "0" },
				{ :color => "white", :type => "rook", :row => "7", :column => "7" },
				{ :color => "white", :type => "bishop", :row => "7", :column => "2" },
				{ :color => "white", :type => "bishop", :row => "7", :column => "5" },
				{ :color => "white", :type => "knight", :row => "7", :column => "1" },
				{ :color => "white", :type => "knight", :row => "7", :column => "6" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "0" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "1" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "2" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "3" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "4" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "5" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "6" },
				{ :color => "white", :type => "pawn", :row => "6", :column => "7" }
			]
			self.pieces = data
		end
end
