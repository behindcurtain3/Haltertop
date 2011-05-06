class AddPromotionToMoves < ActiveRecord::Migration
  def self.up
    add_column :moves, :promotion, :string
  end

  def self.down
    remove_column :moves, :promotion
  end
end
