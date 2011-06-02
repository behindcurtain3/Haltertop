# == Schema Information
# Schema version: 20110530120854
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
#

class Board < ActiveRecord::Base
	belongs_to :game

	attr_accessor :pieces, :turn,					#representation of pieces
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
	# updates the move, returns a move with the updated representation
	# saves a new board if valid move
	def try_move(move)
		setup if !ready?

		# gen all possible moves
		moves = generate_moves(self.pieces, self.turn)
		return nil if moves.length == 0
		valid_move = moves.find { | m | m.from == move.from && m.to == move.to }
		return nil if valid_move.nil?

		# filter out moves that would leave us in check
		moves = filter_for_self_check(self.pieces, moves, self.turn)
		return nil if moves.length == 0
		valid_move = moves.find { | m | m.from == move.from && m.to == move.to }
		return nil if valid_move.nil?

		# perform the move
		valid_move = perform_move(valid_move)

    # self.turn has been swapped, so use it here
    valid_move.check = isCheck(self.turn)

    # check for endgame conditions
    # basically repeat above looking to see if there are any valid moves
    moves = generate_moves(self.pieces, self.turn)
    moves = filter_for_self_check(self.pieces, moves, self.turn)

    # no more moves == game over
    if moves.nil?
      if valid_move.check.nil?
        self.game.result = Game.DRAW
      else
        valid_move.checkmate = true
        
        if self.turn == "w" # black had last move
          self.game.result = Game.BLACK_WIN
        else # white had last move
          self.game.result = Game.WHITE_WIN
        end
      end
      self.game.save
    end

		# create a new board and set it equal to this one, then save it
		next_board = Board.new
		next_board.game = self.game
		next_board.set(self.fen)
		if !next_board.save!
			return nil
		end

		# finally return our move to the game model
		return valid_move
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

	def whos_turn
		setup if !ready?

		if self.turn == "w"
			return self.game.white
		else
			return self.game.black
		end
	end

	def moves(color)
		return generate_moves(self.pieces, color)
	end

	def do_move(move)
		setup if !ready?
		perform_move(move)
	end

	def filter(moves)
		setup if !ready?
		filter_for_self_check(self.pieces, moves, self.turn)
	end

	def get_pieces
		setup if !ready?
		return self.pieces
	end

  # check if color is in check
    def isCheck(color)
			piece_color = (color == "w") ? "white" : "black"
      opponent = (color == "w") ? "b" : "w"

      king = self.pieces.find { |p| p.name == "king" && p.color == piece_color }
      return nil if king.nil?

      # we want to generate moves for ourselves again to see if any pieces attack the king
      board = Board.new
			board.game = self.game
			board.set self.fen
      next_moves = board.moves(opponent)

      next_moves.each do | m |
        if m.to == king.position
          return king.position
        end
      end

      return nil
    end

	private

		def perform_move(move)
			splices = []
			# actually move the pieces now
			self.pieces.each do | piece |

				# we found the piece to move
				if piece.position == move.from
					self.halfmoves += 1
					piece.position = move.to
					move.piece = piece

					if piece.name == "pawn"
						self.halfmoves = 0

					elsif piece.name == "king"
						if self.turn == "w"
							self.K = false
							self.Q = false
						else
							self.k = false
							self.q = false
						end

					elsif piece.name == "rook"
						if move.from.row == 0 && move.from.col == 0
							self.q = false
						elsif move.from.row == 0 && move.from.col == 7
							self.k = false
						elsif move.from.row == 7 && move.from.col == 0
							self.Q = false
						elsif move.from.row == 7 && move.from.col == 7
							self.K = false
						end
					end

				# piece to capture
				elsif piece.position == move.to
					move.capture = piece
					self.halfmoves = 0
					splices.push piece

				# handle castling
				elsif !move.castle.nil?
					if piece.position == move.castle[:from]
						if self.turn == "w"
							self.K = false
							self.Q = false
						else
							self.k = false
							self.q = false
						end
						piece.position = move.castle[:to]
					end
				end
			end

			self.pieces.delete_if { |i|
				splices.include?(i)
			}

      # look for enpassant capture
			unless self.enpassant.nil?
        if move.to == self.enpassant
          lookAt = Point.new((self.turn == "w") ? self.enpassant.row + 1 : self.enpassant.row - 1, self.enpassant.col)

          p = self.pieces.find { |p| p.position == lookAt }
          unless p.nil?
            move.capture = p
            self.pieces.delete p
          end
        end
			end

			#set enpassant status for future moves
			self.enpassant = move.enpassant

			if self.turn == "b"
				self.fullmoves += 1
				move.user = self.game.black
			else
				move.user = self.game.white
			end

      # in check?
      opponent = (self.turn == "w") ? "b" : "w"
			self.turn = opponent

			self.save_fen

			return move
		end

		def generate_moves(pieces, color)
      # stores all moves generated
      move_list = []

      # set the opposite color
      opp_color = (color == "w") ? "black" : "white"
			color = (color == "w") ? "white" : "black"

      pieces.each { | piece |
				#next unless(piece.active)
        next if(piece.color != color)

        case piece.name

        # KING MOVES
        when "king"
          # king can move 1 space each direction
          [[-1,-1],[0,-1],[1,-1], [-1,0],[1,0] ,[-1,1],[0,1],[1,1]].each do | move |
            column = piece.position.col + move[0]
            row = piece.position.row + move[1]
            if valid_index?(column) && valid_index?(row)
              if moveable?(color, column, row)
                move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(row, column))
              end
            end
          end

          # check for castling
          if color == "black"
            # only if the king is at the starting position
            if piece.position.col == 4 && piece.position.row == 0
              if self.k
                # Add 2 to column
                if open?(piece.position.col + 1, piece.position.row) && open?(piece.position.col + 2, piece.position.row)
                  move_list << Move.new(:castle => { :from => Point.new(0, 7), :to => Point.new(0, 5)},
																:from => Point.new(piece.position.row, piece.position.col),
																:to => Point.new(piece.position.row, piece.position.col + 2))
                end
              end

              if self.q
                # - 3 from column
                if open?(piece.position.col - 1, piece.position.row) && open?(piece.position.col - 2, piece.position.row) && open?(piece.position.col - 3, piece.position.row)
									move_list << Move.new(:castle => { :from => Point.new(0, 0), :to => Point.new(0, 3)},
																:from => Point.new(piece.position.row, piece.position.col),
																:to => Point.new(piece.position.row, piece.position.col - 2))
                end
              end
            end
          else #white
            if piece.position.col == 4 && piece.position.row == 7
              if self.K
                # Add 2 to column
                if open?(piece.position.col + 1, piece.position.row) && open?(piece.position.col + 2, piece.position.row)
                  move_list << Move.new(:castle => { :from => Point.new(7, 7), :to => Point.new(7, 5)},
																:from => Point.new(piece.position.row, piece.position.col),
																:to => Point.new(piece.position.row, piece.position.col + 2))
                end
              end

              if self.Q
                # - 3 from column
                if open?(piece.position.col - 1, piece.position.row) && open?(piece.position.col - 2, piece.position.row) && open?(piece.position.col - 3, piece.position.row)
                  move_list << Move.new(:castle => { :from => Point.new(7, 0), :to => Point.new(7, 3)},
																:from => Point.new(piece.position.row, piece.position.col),
																:to => Point.new(piece.position.row, piece.position.col - 2))
                end
              end
            end
          end

        # QUEEN MOVES
        when "queen"
					# left & right moves
					[(piece.position.col-1).downto(0).to_a, (piece.position.col+1..7)].each do | move |
						move.each do | c |
							break unless valid_index?(c)

							if moveable?(color, c, piece.position.row)
								move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(piece.position.row, c))
								break if attack?(opp_color, c, piece.position.row)
							else
								break # break if we can't move to a square since we can't move past it either
							end
						end
					end

					# up & down moves
					[(piece.position.row-1).downto(0).to_a, (piece.position.row+1..7)].each do | move |
						move.each do | r |
							break unless valid_index?(r)

							if moveable?(color, piece.position.col, r)
								move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(r, piece.position.col))
								break if attack?(opp_color, piece.position.col, r)
							else
								break # break if we can't move to a square since we can't move past it either
							end
						end
					end

					# diagonals
					(1..4).each do | direction |
						(1..7).each do | n |
							case direction
								when 1 # lower left
									column = piece.position.col + n
									row = piece.position.row + n
								when 2 # lower right
									column = piece.position.col - n
									row = piece.position.row + n
								when 3 # upper right
									column = piece.position.col + n
									row = piece.position.row - n
								when 4 # upper left
									column = piece.position.col - n
									row = piece.position.row - n
							end

							if valid_index?(column) && valid_index?(row)
								if moveable?(color, column, row)
									move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(row, column))
									break if attack?(opp_color, column, row)
								else
									break # break if we can't move to a square since we can't move past it either
								end
							else
								break
							end
						end
					end

        # ROOK MOVES
        when "rook"
					# left & right moves
					[(piece.position.col-1).downto(0).to_a, (piece.position.col+1..7)].each do | move |
						move.each do | c |
							break unless valid_index?(c)

							if moveable?(color, c, piece.position.row)
								move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(piece.position.row, c))
								break if attack?(opp_color, c, piece.position.row)
							else
								break # break if we can't move to a square since we can't move past it either
							end
						end
					end

					# up & down moves
					[(piece.position.row-1).downto(0).to_a, (piece.position.row+1..7)].each do | move |
						move.each do | r |
							break unless valid_index?(r)

							if moveable?(color, piece.position.col, r)
								move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(r, piece.position.col))
								break if attack?(opp_color, piece.position.col, r)
							else
								break # break if we can't move to a square since we can't move past it either
							end
						end
					end

        # BISHOP MOVES
        when "bishop"
					# from piece towards lower right
					(1..4).each do | direction |
						(1..7).each do | n |
							case direction
								when 1 # lower left
									column = piece.position.col + n
									row = piece.position.row + n
								when 2 # lower right
									column = piece.position.col - n
									row = piece.position.row + n
								when 3 # upper right
									column = piece.position.col + n
									row = piece.position.row - n
								when 4 # upper left
									column = piece.position.col - n
									row = piece.position.row - n
							end

							if valid_index?(column) && valid_index?(row)
								if moveable?(color, column, row)
									move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(row,column))
                  break if attack?(opp_color, column, row)
								else
									break # break if we can't move to a square since we can't move past it either
								end
							else
								break
							end
						end
					end

        # KNIGHT MOVES
        when "knight"
          [[-1,-2],[-2,-1], [1,-2],[2,-1], [-1,2],[-2,1], [1,2], [2,1] ].each do | move |
            column = piece.position.col + move[0]
            row = piece.position.row + move[1]

            if valid_index?(column) && valid_index?(row)
              if moveable?(color, column, row)
								move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(row, column))
              end
            end
          end

        # PAWN MOVES
        when "pawn"
          # changes direction based on color
          row = ((color == "white") ? -1 : 1) + piece.position.row

          if valid_index?(row)

            # check for pawn attacks
            [-1,1].each do | attack |
              column = piece.position.col + attack
              if valid_index?(column)
                if attack?(opp_color, column, row)
									move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(row, column))
                elsif open?(column, row)
                  unless self.enpassant.nil?
                    if self.enpassant.col == column and self.enpassant.row == row
											move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col),	:to => Point.new(row, column))
                    end
                  end
                end
              end
            end

            # check for normal moves
            if open?(piece.position.col, row)
							move_list << Move.new(:from => Point.new(piece.position.row, piece.position.col), :to => Point.new(row, piece.position.col))

              # check for 2 spaces if still at start
              if (piece.position.row == 1 && piece.color == "black") || (piece.position.row == 6 && piece.color == "white")
                enpassant_row = row
                row += ((color == "white") ? -1 : 1)
                if valid_index?(row)
                  if open?(piece.position.col, row)
										move_list << Move.new(:enpassant => Point.new(enpassant_row, piece.position.col),
											:from => Point.new(piece.position.row, piece.position.col),
											:to => Point.new(row, piece.position.col))
                  end
                end
              end
            end
          end
        end

      }
      return move_list
    end

		# removes moves that leave color in check
    def filter_for_self_check(pieces, moves, color)
			color = (color == "w") ? "white" : "black"
			opp_color = (color == "white") ? "b" : "w"
      splices = []
      king = pieces.find { |p| p.name == "king" && p.color == color }
      return [] if king.nil?      

      # for each move we generated go through and see if any opponent moves put color king in check
      moves.each_index do | i |
        mover = pieces.index { |p| p.position == moves[i].from }
        next if mover.nil?

        # is the mover the king? update the king position
        if (pieces[mover].position == king.position)
          king.position = moves[i].to
        end

				board = Board.new
				board.game = self.game
				board.set self.fen
				board.do_move(moves[i])
        opp_moves = board.moves(opp_color)

        opp_moves.each do | omove |
          if (omove.to == king.position)
            # splice out the current move & break... only 1 needs to be found
            splices << moves[i]
            break
          end
        end

        if (pieces[mover].position == king.position)
          king.position = moves[i].from
        end

      end

      moves.delete_if { |i|
        splices.include?(i)
      }

			return nil if moves.length == 0
      return moves
    end

    def valid_index?(i)
			return (i >= 0 && i <= 7)
		end

    # true if space is empty or occupied by piece opposite of {color}, false if occupied by {color}
    def moveable?(color, column, row)
      piece = self.pieces.find { |p| p.color == color && p.position.col == column && p.position.row == row }
      return true if piece.nil?
      return false
    end

    # true if there is no piece present, false otherwise
    def open?(column, row)
      piece = self.pieces.find { |p| p.position.col == column && p.position.row == row }
      return true if piece.nil?
      return false
    end

    # true if occupied by piece of {color}, useful for pawns who can only attack if a square is occupied
    def attack?(color, column, row)
      piece = self.pieces.find { |p| p.color == color && p.position.col == column && p.position.row == row }
      return false if piece.nil?
      return true
    end

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
			castle_fen = ""

			if self.K
				castle_fen += "K"
			end
			if self.Q
				castle_fen += "Q"
			end
			if self.k
				castle_fen += "k"
			end
			if self.q
				castle_fen += "q"
			end

			if castle_fen == ""
				castle_fen = "-"
			end
			fen = fen + castle_fen

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
						position = Point.new(rc, cc)
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
				self.enpassant = Point.new(0,0)
				self.enpassant.set parts[3]
			end

			# half moves counter
			self.halfmoves = parts[4].to_i

			# full moves counter
			self.fullmoves = parts[5].to_i

			self.loaded = true
		end

		def starting_fen
			return "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
		end
end
