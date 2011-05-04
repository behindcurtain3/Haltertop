class AddTurnIdToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :turn_id, :integer
		add_index :games, :turn_id
  end

  def self.down
    remove_column :games, :turn_id
  end
end
