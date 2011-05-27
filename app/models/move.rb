# == Schema Information
# Schema version: 20110527073557
#
# Table name: moves
#
#  id                :integer         not null, primary key
#  game_id           :integer
#  user_id           :integer
#  from_column       :integer
#  to_column         :integer
#  from_row          :integer
#  to_row            :integer
#  captured          :string(255)
#  promoted          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  notation          :string(255)
#  castle            :boolean
#  check             :boolean
#  enpassant         :string(255)
#  enpassant_capture :boolean
#

class Move < ActiveRecord::Base
  serialize :enpassant

	belongs_to :game
	belongs_to :user

	validates :game_id, :presence => true
	validates :user_id, :presence => true

  attr_accessible :game, :user, :enpassant, :enpassant_capture, :from_column, :to_column, :from_row, :to_row, :captured, :promoted, :castle, :check

  FILE_MAP = { 0 => 'a', 1 => 'b', 2 => 'c', 3 => 'd', 4 => 'e', 5 => 'f', 6 => 'g', 7 => 'h' }
  RANK_MAP = { 0 => 8, 1 => 7, 2 => 6, 3 => 5, 4 => 4, 5 => 3, 6 => 2, 7 => 1 }

  def notate(piece)
    n = ""
    # add piece that is moving
    if castle
      if to_column < from_column
        n = "0-0-0"
      else
        n = "0-0"
      end
    else
      n = piece.notation.to_s
      n = n + "x" unless self.captured.nil?
      n = n + column_to_file(self.to_column).to_s + row_to_rank(self.to_row).to_s

      if self.check
        n = n + "+"
      end
    end

    self.notation = n
  end

  def column_to_file(column)
    FILE_MAP.each_pair do |k,v|
			if k == column
        return v
			end
		end
  end

  def row_to_rank(row)
    RANK_MAP.each_pair do |k,v|
			if k == row
        return v
			end
		end
  end

end
