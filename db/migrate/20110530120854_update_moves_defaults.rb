class UpdateMovesDefaults < ActiveRecord::Migration
  def self.up
		change_column :moves, :castle, :string, :default => nil
		change_column :moves, :check, :string, :default => nil
  end

  def self.down
  end
end
