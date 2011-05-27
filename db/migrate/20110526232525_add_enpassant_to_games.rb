class AddEnpassantToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :enpassant, :string

    add_column :moves, :enpassant, :string
    add_column :moves, :enpassant_capture, :boolean
  end

  def self.down
    remove_column :games, :enpassant

    remove_column :moves, :enpassant
    remove_column :moves, :enpassant_capture
  end
end
