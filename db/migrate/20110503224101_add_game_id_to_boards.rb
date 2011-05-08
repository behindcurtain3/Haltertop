class AddGameIdToBoards < ActiveRecord::Migration
  def self.up
    add_column :boards, :game_id, :integer
  end

  def self.down
    remove_column :boards, :game_id
  end
end
