class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :from_column
			t.integer :to_column
			t.integer :from_row
			t.integer :to_row
			t.string	:captured
			t.string	:promoted

      t.timestamps
    end
		add_index :moves, :game_id
		add_index :moves, :user_id
  end

  def self.down
    drop_table :moves
  end
end