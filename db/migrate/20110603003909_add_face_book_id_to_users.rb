class AddFaceBookIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fbid, :string
  end

  def self.down
    remove_column :users, :fbid
  end
end
