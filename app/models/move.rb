# == Schema Information
# Schema version: 20110512230247
#
# Table name: moves
#
#  id          :integer         not null, primary key
#  game_id     :integer
#  user_id     :integer
#  from_column :integer
#  to_column   :integer
#  from_row    :integer
#  to_row      :integer
#  captured    :string(255)
#  promoted    :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  notation    :string(255)
#  castle      :boolean
#

class Move < ActiveRecord::Base
	belongs_to :game
	belongs_to :user

	validates :game_id, :presence => true
	validates :user_id, :presence => true

end
