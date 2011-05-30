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

#attr_accessible :game, :user,
#		:from, :to,
#		:capture, :promoted, :castle, :check, :enpassant, :notation


class UpdateMoves < ActiveRecord::Migration
  def self.up
		remove_column :moves, :from_column
		remove_column :moves, :to_column
		remove_column :moves, :from_row
		remove_column :moves, :to_row
		remove_column :moves, :enpassant_capture

		add_column :moves, :from, :string
		add_column :moves, :to, :string
		
		rename_column :moves, :captured, :capture

		change_column :moves, :castle, :string
		change_column :moves, :check, :string
  end

  def self.down
  end
end
