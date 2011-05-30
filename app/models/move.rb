# == Schema Information
# Schema version: 20110530123612
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
#

class Move < ActiveRecord::Base
  serialize :enpassant
	serialize :from
	serialize :to
	serialize :capture
	serialize :check

	belongs_to :game
	belongs_to :user

	validates :game_id, :presence => true
	validates :user_id, :presence => true

  attr_accessible :game, :user, 
		:from, :to,
		:capture, :promoted, :castle, :check, :enpassant, :notation


  

  def notate(piece)
    n = ""
    # add piece that is moving
    if !castle.nil?
      if self.castle == "q" || self.castle == "Q"
        n = "0-0-0"
      else
        n = "0-0"
      end
    else
      n = piece.notation
      n = n + "x" unless self.capture.nil?
      n = n + self.to.notation

      if !self.check.nil?
        n = n + "+"
      end
    end

    self.notation = n
  end

end
