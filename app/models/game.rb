# == Schema Information
# Schema version: 20110509040216
#
# Table name: games
#
#  id         :integer         not null, primary key
#  black_id   :integer
#  white_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  turn_id    :integer
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
		# Sequence of events:
		# 1. Find the piece moved, if nil return failed
		# 2. Generate list of all valid moves
		# 3. If our move is not on the list return failed
		# 4. If it is on the list:
		#		a. Check for endgame condition
		#		b. Update castling status
		#		c. Update en passant status
		#		d. Update the piece(s).
		#		e. Generate move & push to users
		#		f. If promotion... ask the user which piece to promote to

    # Step 1: find our piece
    piece = Piece.find(:first, :conditions => ["game_id = ? AND row = ? AND column = ? AND active = ?", self.id, from_r, from_c, true])

    # return false if the piece wasn't found
    if piece.nil?
      result = {
        :status => "failed",
        :title => "Hmm, something went wrong",
        :text => "The move you tried doesn't jive with our system. We're pretty sure you can find a better one anyways."
      }
      return result
    end

		# Prep our new move
    m = Move.new(:from_column => from_c, :to_column => to_c, :from_row => from_r, :to_row => to_r, :game => self, :user => self.turn)

    moves = generate_moves
		#moves.each do | print |
		#	puts "#{print.from_column}, #{print.from_row} - #{print.to_column}, #{print.to_row}"
		#end
    valid_move = moves.find {|move| move.from_column == m.from_column && move.to_column == m.to_column && move.from_row == m.from_row && move.to_row == m.to_row }
		
    if valid_move.nil?
      # requested move not found
      result = {
        :status => "failed",
        :title => "Invalid Move",
        :text => "The move you tried doesn't jive with the rules. We're pretty sure you can find a better one anyways."
      }
      return result
    end

		# Step 4e setup our result hash
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

    # update our piece
    piece[:row] = to_r
    piece[:column] = to_c

    # See if there is an attacked piece
    attacked = Piece.find(:first, :conditions => ["game_id = ? AND row = ? AND column = ? AND active = ?", self.id, to_r, to_c, true])

    unless attacked.nil?
      m.captured = attacked[:name]
      attacked[:active] = false
      attacked.save

      # add capture to our result
      result[:capture] = true
    end

    # if the move was a castle, we need to add the rook movement to the result hash
    if valid_move.castle
      # find the column
      f_column = 0 # 0 for both sides
      t_column = 3
      if m.from_column < m.to_column
          f_column = 7
          t_column = 5
      end

      rook = Piece.find(:first, :conditions => ["game_id = ? AND row = ? AND column = ? AND active = ?", self.id, m.from_row, f_column, true])

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

    # save our move
    m.save

    # save the piece
		piece.save

		# Update castling status
		# check the 4 corners and king start position
		if self.black_king_side_castle || self.black_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'king' && piece.column == 4 && piece.row == 0 && piece.active == true }
			if p.nil?
				self.black_queen_side_castle = false
				self.black_king_side_castle = false
			end
		end
		if self.white_king_side_castle || self.white_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'king' && piece.column == 4 && piece.row == 7 && piece.active == true }
			if p.nil?
				self.white_queen_side_castle = false
				self.white_king_side_castle = false
			end
		end

		if self.black_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 0 && piece.row == 0 && piece.active == true }
			if p.nil?
				self.black_queen_side_castle = false
			end
		end
		if self.black_king_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 7 && piece.row == 0 && piece.active == true }
			if p.nil?
				self.black_king_side_castle = false
			end
		end
		if self.white_queen_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 0 && piece.row == 7 && piece.active == true }
			if p.nil?
				self.white_queen_side_castle = false
			end
		end
		if self.white_king_side_castle
			p = self.pieces.to_a.find { |piece| piece.name == 'rook' && piece.column == 7 && piece.row == 7 && piece.active == true }
			if p.nil?
				self.white_king_side_castle = false
			end
		end

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

		def generate_moves
      # stores all moves generated
      move_list = []

      # who's turn is it?
      color = (self.turn == self.white) ? "white" : "black"
      opp_color = (self.turn == self.white) ? "black" : "white"

      self.pieces.each { | piece |
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
