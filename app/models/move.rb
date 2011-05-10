# == Schema Information
# Schema version: 20110509040216
#
# Table name: moves
#
#  id          :integer         not null, primary key
#  game_id     :integer
#  user_id     :integer
#  from_column :integer
#  to_column   :integer
#  from_row    :integer
#  to_row      :integer
#  captured    :string(255)
#  promoted    :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Move < ActiveRecord::Base
	belongs_to :game
	belongs_to :user

	validates :game_id, :presence => true
	validates :user_id, :presence => true

	NOTATION_MAP = { 'king' => 'K', 'queen' => 'Q', 'rook' => 'R', 'bishop' => 'B', 'knight' => 'N' }

	# Takes a piece type, column & row and returns the proper notation
	def to_notation
		notation = ''

		# Add piece to notation, if not a pawn
		unless self.piece == 'pawn'
			NOTATION_MAP.each do |type|
				if type.key == self.piece
					notation = type.value
				end
			end
			
			# is it a capture?
			if self.capture
				notation += 'x'
			end

			# add file
			notation += self.file
			#add rank
			notation += self.rank
		else
			# for a pawns
			if self.capture
				# if a capture add the s
			end
		end
	end

	def column_to_file(column)

	end
end
