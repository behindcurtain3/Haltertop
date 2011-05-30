class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
			t.integer :game_id
      t.string :fen
      t.string :algebraic
			t.integer :move_number

      t.timestamps
    end

		add_index :boards, :game_id
  end

  def self.down
    drop_table :boards
  end
end
