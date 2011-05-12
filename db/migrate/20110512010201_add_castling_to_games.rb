class AddCastlingToGames < ActiveRecord::Migration
  def self.up
		# booleans to track status of castling
    add_column :games, :black_queen_side_castle, :boolean, :default => true
    add_column :games, :black_king_side_castle, :boolean, :default => true

    add_column :games, :white_queen_side_castle, :boolean, :default => true
    add_column :games, :white_king_side_castle, :boolean, :default => true
  end

  def self.down
    remove_column :games, :black_king_side_castle
    remove_column :games, :black_queen_side_castle

		remove_column :games, :white_king_side_castle
    remove_column :games, :white_queen_side_castle

  end
end
