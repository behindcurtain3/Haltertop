class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.integer :game_id
      t.integer :user_id
      t.string :piece
			t.string :rank
			t.string :file

      t.timestamps
    end
		add_index :moves, :game_id
		add_index :moves, :user_id
  end

  def self.down
    drop_table :moves
  end
end