class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :black_id
      t.integer :white_id

      t.timestamps
    end
		add_index :games, :black_id
		add_index :games, :white_id
  end

  def self.down
    drop_table :games
  end
end
