class Piece < ActiveRecord::Base
  belongs_to :game

  attr_accessible :name, :color, :column, :row, :active, :game
end
