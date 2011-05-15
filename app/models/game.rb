# == Schema Information
# Schema version: 20110512230247
#
# Table name: games
#
#  id                      :integer         not null, primary key
#  black_id                :integer
#  white_id                :integer
#  created_at              :datetime
#  updated_at              :datetime
#  turn_id                 :integer
#  black_queen_side_castle :boolean         default(TRUE)
#  black_king_side_castle  :boolean         default(TRUE)
#  white_queen_side_castle :boolean         default(TRUE)
#  white_king_side_castle  :boolean         default(TRUE)
#

class Game < ActiveRecord::Base
	# moves
	has_many :moves, :dependent => :destroy
  has_many :pieces, :dependent => :destroy

	# User relationships
	belongs_to :black, :class_name => "User"
	belongs_to :white, :class_name => "User"
	belongs_to :turn, :class_name => "User"

	# before creating a game run setup_game
	before_create :setup_game
  after_create :setup_pieces

	def move(from_r, to_r, from_c, to_c)
    unless self.active
      result = {
        :status => "failed",
        :title => "G-g-game Over!",
        :text => "Sorry, but the current game has finished! Try your hand in a new one."
      }
      return result
    end


    # Step 1: find our piece
    piece = Piece.find(:first, :conditions => ["game_id = ? AND row = ? AND column = ?", self.id, from_r, from_c])

    # return false if the piece wasn't found
    if piece.nil?
      result = {
        :status => "failed",
        :title => "Hmm, something went wrong",
        :text => "The move you tried doesn't jive with our system. We're pretty sure you can find a better one anyways."
      }
      return result
    end

		# Step 2: Prepare our new move
    m = Move.new(:from_column => from_c, :to_column => to_c, :from_row => from_r, :to_row => to_r, :game => self, :user => self.turn)

    # Step 3: Generate valid moves
    moves = generate_moves(self.pieces.to_a, whos_turn)

    # Step 3b: remove any moves generated that put their own side in check
    moves = filter_check(moves, whos_turn)

    # if the player has no moves
    if moves.length == 0
      self.active = false
      self.save
    end

		# Step 4: Is requested move found in the valid moves?
    valid_move = moves.find {|move| move.from_column == m.from_column && move.to_column == m.to_column && move.from_row == m.from_row && move.to_row == m.to_row }

    # return failed response if not a valid move
    if valid_move.nil?
      # requested move not found
      result = {
        :status => "failed",
        :title => "Invalid Move",
        :text => "The move you tried doesn't jive with the rules. We're pretty sure you can find a better one anyways."
      }
      return result
    end

		# Step 5: setup our result hash
		result = {
			:status => "success",
			:move => [{
				:from_column => from_c,
				:to_column => to_c,
				:from_row => from_r,
				:to_row => to_r
			}],
			:turn => self.whos_turn,
			:capture => false
		}

    # Step 6: update our piece
    piece[:row] = to_r
    piece[:column] = to_c

    # Step 7: see if there is an attacked piece
    attacked = Piece.find(:first, :conditions => ["game_id = ? AND row = ? AND column = ?", self.id, to_r, to_c])

    # if so set it to false & update
    unless attacked.nil?
      m.captured = attacked[:name]
      attacked.destroy

      # add capture to our result
      result[:capture] = true
    end

    # Step 8: if the move was a castle, we need to add the rook movement to the result hash
    if valid_move.castle
      # find the column
      f_column = 0 # 0 for both sides
      t_column = 3
      if m.from_column < m.to_column
          f_column = 7
          t_column = 5
      end

      rook = Piece.find(:first, :conditions => ["game_id = ? AND row = ? AND column = ?", self.id, m.from_row, f_column])

      unless rook.nil?
        rook[:column] = t_column
        rook.save
        result[:move] << {
          :from_column => f_column,
          :to_column => t_column,
          :from_row => m.from_row,
          :to_row => m.to_row
        }
      end
    end

    # Step 9: save our move & the piece
    m.save
		piece.save

		# Step 10: Update castling status
		# check the 4 corners and king start position
		if self.black_king_side_castle || self.black_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'king' && piece.column == 4 && piece.row == 0 }
			if p.nil?
				self.black_queen_side_castle = false
				self.black_king_side_castle = false
			end
		end
		if self.white_king_side_castle || self.white_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'king' && piece.column == 4 && piece.row == 7 }
			if p.nil?
				self.white_queen_side_castle = false
				self.white_king_side_castle = false
			end
		end

		if self.black_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 0 && piece.row == 0 }
			if p.nil?
				self.black_queen_side_castle = false
			end
		end
		if self.black_king_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 7 && piece.row == 0 }
			if p.nil?
				self.black_king_side_castle = false
			end
		end
		if self.white_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 0 && piece.row == 7 }
			if p.nil?
				self.white_queen_side_castle = false
			end
		end
		if self.white_king_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 7 && piece.row == 7 }
			if p.nil?
				self.white_king_side_castle = false
			end
		end

    # Step 11: swap turns and update game
		swap_turns # swap turns
    result[:turn] = self.whos_turn
		self.save
		return result
	end

	def whos_turn
		if self.turn == self.white
			return "white"
		else
			return "black"
		end
	end

	private

		def setup_game
			unless self.white.nil?
				self.turn = self.white
			end
		end

		def swap_turns
			if self.turn == self.white
				self.turn = self.black
			else
				self.turn = self.white
			end
		end

		def generate_moves(pieces, color)
      # stores all moves generated
      move_list = []

      # set the opposite color
      opp_color = (color == "white") ? "black" : "white"

      pieces.each { | piece |
				next unless(piece.active)
        next if(piece.color != color)
          
        case piece.name

        # KING MOVES
        when "king"
          # king can move 1 space each direction
          [[-1,-1],[0,-1],[1,-1], [-1,0],[1,0] ,[-1,1],[0,1],[1,1]].each do | move |
            column = piece.column + move[0]
            row = piece.row + move[1]
            if valid_index?(column) && valid_index?(row)
              if moveable?(color, column, row)
                move_list << Move.new(:from_column => piece.column, :to_column => column, :from_row => piece.row, :to_row => row)
              end
            end
          end

          # check for castling
          if color == "black"
            # only if the king is at the starting position
            if piece.column == 4 && piece.row == 0
              if self.black_king_side_castle
                # Add 2 to column
                if open?(piece.column + 1, piece.row) && open?(piece.column + 2, piece.row)
                  move_list << Move.new(:castle => true, :from_column => piece.column, :to_column => piece.column + 2, :from_row => piece.row, :to_row => piece.row)
                end
              end

              if self.black_queen_side_castle
                # - 3 from column
                if open?(piece.column - 1, piece.row) && open?(piece.column - 2, piece.row) && open?(piece.column - 3, piece.row)
                  move_list << Move.new(:castle => true, :from_column => piece.column, :to_column => piece.column - 2, :from_row => piece.row, :to_row => piece.row)
                end
              end
            end
          else #white
            if piece.column == 4 && piece.row == 7
              if self.white_king_side_castle
                # Add 2 to column
                if open?(piece.column + 1, piece.row) && open?(piece.column + 2, piece.row)
                  move_list << Move.new(:castle => true, :from_column => piece.column, :to_column => piece.column + 2, :from_row => piece.row, :to_row => piece.row)
                end
              end

              if self.white_queen_side_castle
                # - 3 from column
                if open?(piece.column - 1, piece.row) && open?(piece.column - 2, piece.row) && open?(piece.column - 3, piece.row)
                  move_list << Move.new(:castle => true, :from_column => piece.column, :to_column => piece.column - 2, :from_row => piece.row, :to_row => piece.row)
                end
              end
            end
          end

        # QUEEN MOVES
        when "queen"
					# left & right moves
					[(piece.column-1).downto(0).to_a, (piece.column+1..7)].each do | move |
						move.each do | c |
							break unless valid_index?(c)

							if moveable?(color, c, piece.row)
								move_list << Move.new(:from_column => piece.column, :to_column => c, :from_row => piece.row, :to_row => piece.row)
								break if attack?(opp_color, c, piece.row)
							else
								break # break if we can't move to a square since we can't move past it either
							end
						end
					end

					# up & down moves
					[(piece.row-1).downto(0).to_a, (piece.row+1..7)].each do | move |
						move.each do | r |
							break unless valid_index?(r)

							if moveable?(color, piece.column, r)
								move_list << Move.new(:from_column => piece.column, :to_column => piece.column, :from_row => piece.row, :to_row => r)
								break if attack?(opp_color, piece.column, r)
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
									column = piece.column + n
									row = piece.row + n
								when 2 # lower right
									column = piece.column - n
									row = piece.row + n
								when 3 # upper right
									column = piece.column + n
									row = piece.row - n
								when 4 # upper left
									column = piece.column - n
									row = piece.row - n
							end

							if valid_index?(column) && valid_index?(row)
								if moveable?(color, column, row)
									move_list << Move.new(:from_column => piece.column, :to_column => column, :from_row => piece.row, :to_row => row)
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
					[(piece.column-1).downto(0).to_a, (piece.column+1..7)].each do | move |
						move.each do | c |
							break unless valid_index?(c)

							if moveable?(color, c, piece.row)
								move_list << Move.new(:from_column => piece.column, :to_column => c, :from_row => piece.row, :to_row => piece.row)
								break if attack?(opp_color, c, piece.row)
							else
								break # break if we can't move to a square since we can't move past it either
							end
						end
					end

					# up & down moves
					[(piece.row-1).downto(0).to_a, (piece.row+1..7)].each do | move |
						move.each do | r |
							break unless valid_index?(r)

							if moveable?(color, piece.column, r)
								move_list << Move.new(:from_column => piece.column, :to_column => piece.column, :from_row => piece.row, :to_row => r)
								break if attack?(opp_color, piece.column, r)
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
									column = piece.column + n
									row = piece.row + n
								when 2 # lower right
									column = piece.column - n
									row = piece.row + n
								when 3 # upper right
									column = piece.column + n
									row = piece.row - n
								when 4 # upper left
									column = piece.column - n
									row = piece.row - n
							end
							
							if valid_index?(column) && valid_index?(row)
								if moveable?(color, column, row)
									move_list << Move.new(:from_column => piece.column, :to_column => column, :from_row => piece.row, :to_row => row)
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
            column = piece.column + move[0]
            row = piece.row + move[1]
            
            if valid_index?(column) && valid_index?(row)
              if moveable?(color, column, row)
                move_list << Move.new(:from_column => piece.column, :to_column => column, :from_row => piece.row, :to_row => row)
              end
            end
          end

        # PAWN MOVES
        when "pawn"
          # changes direction based on color
          row = ((color == "white") ? -1 : 1) + piece.row

          if valid_index?(row)
            # check for pawn attacks
            [-1,1].each do | attack |
              column = piece.column + attack
              if valid_index?(column)
                if attack?(opp_color, column, row)
                  move_list << Move.new(:from_column => piece.column, :to_column => column, :from_row => piece.row, :to_row => row)
                end
              end
            end

            # check for normal moves
            if open?(piece.column, row)
              move_list << Move.new(:from_column => piece.column, :to_column => piece.column, :from_row => piece.row, :to_row => row)

              # check for 2 spaces if still at start
              if (piece.row == 1 && piece.color == "black") || (piece.row == 6 && piece.color == "white")
                row += ((color == "white") ? -1 : 1)
                if valid_index?(row)
                  if open?(piece.column, row)
                    move_list << Move.new(:from_column => piece.column, :to_column => piece.column, :from_row => piece.row, :to_row => row)
                  end
                end
              end
            end
          end
        end

      }
      return move_list
    end

    def valid_index?(i)
			return (i >= 0 && i <= 7)
		end

    # true if space is empty or occupied by piece opposite of {color}, false if occupied by {color}
    def moveable?(color, column, row)
      piece = self.pieces.to_ary.find { |p| p.color == color && p.column == column && p.row == row && p.active == true }
      return true if piece.nil?
      return false
    end

    # true if there is no piece present, false otherwise
    def open?(column, row)
      piece = self.pieces.to_ary.find { |p| p.column == column && p.row == row && p.active == true }
      return true if piece.nil?
      return false
    end

    # true if occupied by piece of {color}, useful for pawns who can only attack if a square is occupied
    def attack?(color, column, row)
      piece = self.pieces.to_ary.find { |p| p.color == color && p.column == column && p.row == row && p.active == true }
      return false if piece.nil?
      return true
    end

    # removes moves that leave color in check
    def filter_check(moves, color)
      
      splices = []
      pieces = self.pieces.to_a
      king = pieces.find { |p| p.name == "king" && p.color == color }
      return [] if king.nil?

      # set the opposite color
      opp_color = (color == "white") ? "black" : "white"

      #puts "Color: #{color}"
      puts "Length: #{moves.length}"
      #puts "King: #{king.column}, #{king.row}"

      # for each move we generated go through and see if any opponent moves put color king in check
      moves.each_index do | i |
        mover = pieces.index { |p| p.column == moves[i].from_column && p.row == moves[i].from_row }
        next if mover.nil?

        # is the mover the king? update the king position
        if (pieces[mover].column == king.column && pieces[mover].row == king.row)
          king.column = moves[i].to_column
          king.row = moves[i].to_row
        end

        #puts "Move: #{pieces[mover].name} - #{moves[i].from_column},#{moves[i].from_row} #{moves[i].to_column},#{moves[i].to_row} K: #{king.column},#{king.row}"

        pieces = perform_pseudo_move(pieces, moves[i], mover)

        opp_moves = generate_moves(pieces, opp_color)
        
        opp_moves.each do | omove |
          #puts "Move: #{omove.from_column}, #{omove.from_row}"
          if (omove.to_column == king.column && omove.to_row == king.row)
            # splice out the current move & break... only 1 needs to be found
            splices << moves[i]
            #puts "^^^ SLICED ^^^"
            break
          end
        end

        if (pieces[mover].column == king.column && pieces[mover].row == king.row)
          king.column = moves[i].from_column
          king.row = moves[i].from_row
        end

        pieces = undo_pseudo_move(pieces, moves[i], mover)
      end
      puts "Splices: #{splices.length}"

      moves.delete_if { |i|
        #puts "#{i} --- #{splices.include?(i)}"
        splices.include?(i)
      }

      return moves
    end

    def perform_pseudo_move(pieces, move, index)
      captured = pieces.index { |p| p.name != "king" && p.column == move.to_column && p.row == move.to_row && p.active }
      unless captured.nil?
        #puts captured.to_s
        pieces[captured].active = false
      end

      pieces[index].column = move.to_column
      pieces[index].row = move.to_row

      if move.castle
        # find the column
        f_column = 0 # 0 for both sides
        t_column = 3
        if move.from_column < move.to_column
            f_column = 7
            t_column = 5
        end

        rook = pieces.index { |p| p.column == f_column && p.row == move.from_row && p.active }

        unless rook.nil?
          pieces[rook].column = t_column
        end
      end

      return pieces
    end

    def undo_pseudo_move(pieces, move, index)
      captured = pieces.index { |p| p.name != "king" && p.column == move.to_column && p.row == move.to_row && p.active == false}
      unless captured.nil?
        #puts captured.to_s
        pieces[captured].active = true
      end

      pieces[index].column = move.from_column
      pieces[index].row = move.from_row

      if move.castle
        # find the column
        f_column = 0 # 0 for both sides
        t_column = 3
        if move.from_column < move.to_column
            f_column = 7
            t_column = 5
        end

        rook = pieces.index { |p| p.column == t_column && p.row == move.from_row && p.active }

        unless rook.nil?
          pieces[rook].column = f_column
        end
      end

      return pieces
    end

    def setup_pieces
      Piece.create( :color => "black", :name => "king", :row => "0", :column => "4", :game => self)
      Piece.create( :color => "black", :name => "queen", :row => "0", :column => "3", :game => self)
      Piece.create( :color => "black", :name => "rook", :row => "0", :column => "0", :game => self)
      Piece.create( :color => "black", :name => "rook", :row => "0", :column => "7", :game => self)
      Piece.create( :color => "black", :name => "bishop", :row => "0", :column => "2", :game => self)
      Piece.create( :color => "black", :name => "bishop", :row => "0", :column => "5", :game => self)
      Piece.create( :color => "black", :name => "knight", :row => "0", :column => "1", :game => self)
      Piece.create( :color => "black", :name => "knight", :row => "0", :column => "6", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "0", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "1", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "2", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "3", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "4", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "5", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "6", :game => self)
      Piece.create( :color => "black", :name => "pawn", :row => "1", :column => "7", :game => self)
      Piece.create( :color => "white", :name => "king", :row => "7", :column => "4", :game => self)
      Piece.create( :color => "white", :name => "queen", :row => "7", :column => "3", :game => self)
      Piece.create( :color => "white", :name => "rook", :row => "7", :column => "0", :game => self)
      Piece.create( :color => "white", :name => "rook", :row => "7", :column => "7", :game => self)
      Piece.create( :color => "white", :name => "bishop", :row => "7", :column => "2", :game => self)
      Piece.create( :color => "white", :name => "bishop", :row => "7", :column => "5", :game => self)
      Piece.create( :color => "white", :name => "knight", :row => "7", :column => "1", :game => self)
      Piece.create( :color => "white", :name => "knight", :row => "7", :column => "6", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "0", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "1", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "2", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "3", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "4", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "5", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "6", :game => self)
      Piece.create( :color => "white", :name => "pawn", :row => "6", :column => "7", :game => self)
		end
end