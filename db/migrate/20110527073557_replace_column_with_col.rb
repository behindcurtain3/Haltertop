class ReplaceColumnWithCol < ActiveRecord::Migration
  def self.up
		rename_column :pieces, :column, :col
  end

  def self.down
  end
end
