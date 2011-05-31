class RemoveTurnFromGames < ActiveRecord::Migration
  def self.up
		remove_column :games, :turn_id
  end

  def self.down
		add_column :games, :turn_id, :integer
  end
end
