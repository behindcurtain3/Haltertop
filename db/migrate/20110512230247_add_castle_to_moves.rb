class AddCastleToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :castle, :boolean, :default => false
  end

  def self.down
    remove_column :moves, :castle
  end
end
