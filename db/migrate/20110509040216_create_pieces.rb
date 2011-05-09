class CreatePieces < ActiveRecord::Migration
  def self.up
    create_table :pieces do |t|
      t.string :name
      t.string :color
      t.integer :column
      t.integer :row
      t.boolean :active, :default => true
      t.integer :game_id
    end
    add_index :pieces, :game_id
  end

  def self.down
    drop_table :pieces
  end
end
