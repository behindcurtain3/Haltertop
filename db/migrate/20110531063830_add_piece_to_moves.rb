class AddPieceToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :piece, :string
  end

  def self.down
    remove_column :moves, :piece
  end
end
