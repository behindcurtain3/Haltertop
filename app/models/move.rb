# == Schema Information
# Schema version: 20110531063830
#
# Table name: moves
#
#  id         :integer         not null, primary key
#  game_id    :integer
#  user_id    :integer
#  capture    :string(255)
#  promoted   :string(255)
#  created_at :datetime
#  updated_at :datetime
#  notation   :string(255)
#  castle     :string(255)
#  check      :string(255)
#  enpassant  :string(255)
#  from       :string(255)
#  to         :string(255)
#  piece      :string(255)
#

class Move < ActiveRecord::Base
  serialize :enpassant, Point
	serialize :from, Point
	serialize :to, Point
	serialize :capture, Piece
	serialize :check, Point
	serialize :piece, Piece

	belongs_to :game
	belongs_to :user

	validates :game_id, :presence => true
	validates :user_id, :presence => true

  attr_accessible :game, :user, 
		:from, :to, :piece,
		:capture, :promoted, :castle, :check, :enpassant, :notation


  

  def notate
    n = ""
    # add piece that is moving
    if !castle.nil?
      if self.castle[:from].col < self.castle[:to].col
        n = "0-0-0"
      else
        n = "0-0"
      end
    else
      if self.piece.name != "pawn"
        n = self.piece.notation
      end
      n = n + "x" unless self.capture.nil?
      n = n + self.to.notation

      unless self.check.nil?
        n = n + "+"
      end
    end

    self.notation = n
  end

end
