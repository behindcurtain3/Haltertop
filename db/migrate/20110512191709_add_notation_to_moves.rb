class AddNotationToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :notation, :string
  end

  def self.down
    remove_column :moves, :notation
  end
end
