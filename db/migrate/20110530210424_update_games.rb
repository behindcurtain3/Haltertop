#  black_queen_side_castle :boolean         default(TRUE)
#  black_king_side_castle  :boolean         default(TRUE)
#  white_queen_side_castle :boolean         default(TRUE)
#  white_king_side_castle  :boolean         default(TRUE)
#  active                  :boolean         default(TRUE)
#  result                  :string(255)
#  enpassant               :string(255)

class UpdateGames < ActiveRecord::Migration
  def self.up
		remove_column :games, :black_queen_side_castle
		remove_column :games, :black_king_side_castle
		remove_column :games, :white_queen_side_castle
		remove_column :games, :white_king_side_castle
		remove_column :games, :active
		remove_column :games, :enpassant
  end

  def self.down
  end
end
