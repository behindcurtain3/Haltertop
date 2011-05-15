class AddActiveToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :active, :boolean, :default => true
    add_column :games, :result, :string
  end

  def self.down
    remove_column :games, :result
    remove_column :games, :active
  end
end
