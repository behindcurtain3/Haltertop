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

require 'pusher'

Pusher.app_id = '5414'
Pusher.key = 'e0b03bb1cb7d458de516'
Pusher.secret = '8a8e8d9612f7391352e8'

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
    m = Move.new
    m.from_column = from_c
    m.to_column = to_c
    m.from_row = from_r
    m.to_row = to_r
    m.game = self
    m.user = self.turn

		# moves = generate_moves
		# if moves contains m return valid
		# else return fail

		# Step 4e setup our result hash
		result = {
			:status => "success",
			:move => {
				:from_column => from_c,
				:to_column => to_c,
				:from_row => from_r,
				:to_row => to_r
			},
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

    # save our move
    m.save

    # save the piece
		piece.save

    # swap turns
		swap_turns
    result[:turn] = self.whos_turn
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
			self.save
		end

		def valid_move (piece, move)
			

			return result
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
