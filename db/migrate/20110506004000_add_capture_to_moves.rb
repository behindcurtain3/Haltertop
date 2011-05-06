class AddCaptureToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :capture, :boolean
  end

  def self.down
    remove_column :moves, :capture
  end
end
