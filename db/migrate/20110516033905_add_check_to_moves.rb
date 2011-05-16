class AddCheckToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :check, :boolean, :default => false
  end

  def self.down
    remove_column :moves, :check
  end
end
