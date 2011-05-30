# == Schema Information
# Schema version: 20110530123612
#
# Table name: boards
#
#  id          :integer         not null, primary key
#  game_id     :integer
#  fen         :string(255)
#  algebraic   :string(255)
#  move_number :integer
#  created_at  :datetime
#  updated_at  :datetime
#  turn_id     :integer
#

class Board < ActiveRecord::Base
	belongs_to :game

	attr_accessor :pieces, :turn,							#representation of pieces
		:k, :q, :K, :Q,											#castling
		:enpassant, :halfmoves, :fullmoves,	#enpassant square & move counters
		:loaded
	attr_accessible :game, :algebraic, :move_number

	before_save :save_fen

	# set the board to a fen string
	def set(str)
		import_fen(str)
	end	

	# Takes a move model and attempts to perform the move
	# updates the move, returns a ~new~ Board with the updated representation
	def do_move(move)
		setup if !ready?
	end

	def ready?
		return false if self.loaded.nil? || !self.loaded rescue true
	end

	def setup
		import_fen(self.fen)
	end

	def init
		import_fen(starting_fen)
	end

	def save_fen
		self.fen = export_fen
	end

	private

		# takes pieces etc and produces a fen string
		def export_fen
			return false if self.pieces.nil?

			fen = ""

			# export pieces
			(0..7).each do | row |
				empties = 0 # reset each time through
				(0..7).each do | col |
					piece = self.pieces.find { |p| p.position.row == row && p.position.col == col }
					if piece.nil?
						empties += 1

						# if the last piece is nil, always dump the empties
						if col == 7
							fen = fen + empties.to_s
						end
					else
						if empties > 0
							fen = fen + empties.to_s
							empties = 0
						end
						fen = fen + piece.notation
					end
				end
				if row < 7
					fen = fen + "/"
				end
			end

			#add spacer
			fen = fen + " "

			#export turn
			fen = fen + self.turn + " "

			#export castling
			if !self.k && !self.q && !self.K && !self.Q
				fen = fen + "-"
			else
				if self.K
					fen = fen + "K"
				end
				if self.q
					fen = fen + "Q"
				end
				if self.k
					fen = fen + "k"
				end
				if self.q
					fen = fen + "q"
				end
			end

			fen = fen + " " #add spacer

			# export enpassant
			if self.enpassant.nil?
				fen = fen + "- "
			else
				fen = fen + self.enpassant.notation + " "
			end

			# export half moves
			fen = fen + self.halfmoves.to_s + " "

			# export full moves
			fen = fen + self.fullmoves.to_s

			return fen
		end

		# Takes our fen notation and sets up the accessor variables
		def import_fen(str)
			return false if str.nil?
			
			parts = str.split
			return false if parts.length != 6

			self.fen = str
			self.pieces = Array.new
			
			# contains 8 rows of the board split by /
			rows = parts[0].split("/")

			rc = 0	# row count
			cc = 0	# col count
			rows.each do | row |
				row.to_s.each_char do | c |
					if c.is_number?
						cc += c.to_i - 1
					else
						# set col & row, set to white by default so we save half the effort below
						p = Piece.new
						p.color = "white"
						position = Point.new
						position.col = cc
						position.row = rc
						p.position = position
						case c
						when "k"
								p.name = "king"
								p.color = "black"
						when "q"
								p.name = "queen"
								p.color = "black"
						when "r"
								p.name = "rook"
								p.color = "black"
						when "b"
								p.name = "bishop"
								p.color = "black"
						when "n"
								p.name = "knight"
								p.color = "black"
						when "p"
								p.name = "pawn"
								p.color = "black"
						when "K"
								p.name = "king"
						when "Q"
								p.name = "queen"
						when "R"
								p.name = "rook"
						when "B"
								p.name = "bishop"
						when "N"
								p.name = "knight"
						when "P"
								p.name = "pawn"
						end

						self.pieces.push p
					end
					
					cc += 1
				end
				cc = 0
				rc += 1
			end

			# setup turn
			self.turn = parts[1]

			# setup castling
			self.k = false
			self.q = false
			self.K = false
			self.Q = false
			if parts[2].include?("k")
				self.k = true
			end
			if parts[2].include?("q")
				self.q = true
			end
			if parts[2].include?("K")
				self.K = true
			end
			if parts[2].include?("Q")
				self.Q = true
			end

			# setup enpassant
			if parts[3] == "-"
				self.enpassant = nil
			else
				self.enpassant = Point.new
				self.enpassant.set parts[3]
			end

			# half moves counter
			self.halfmoves = parts[4]

			# full moves counter
			self.fullmoves = parts[5]

			self.loaded = true
		end

		def starting_fen
			return "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
		end
end
