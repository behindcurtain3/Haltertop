# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110509040216) do

  create_table "boards", :force => true do |t|
    t.text     "pieces"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_id"
  end

  create_table "games", :force => true do |t|
    t.integer  "black_id"
    t.integer  "white_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "turn_id"
  end

  add_index "games", ["black_id"], :name => "index_games_on_black_id"
  add_index "games", ["turn_id"], :name => "index_games_on_turn_id"
  add_index "games", ["white_id"], :name => "index_games_on_white_id"

  create_table "moves", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "from_column"
    t.integer  "to_column"
    t.integer  "from_row"
    t.integer  "to_row"
    t.string   "captured"
    t.string   "promoted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moves", ["game_id"], :name => "index_moves_on_game_id"
  add_index "moves", ["user_id"], :name => "index_moves_on_user_id"

  create_table "pieces", :force => true do |t|
    t.string  "name"
    t.string  "color"
    t.integer "column"
    t.integer "row"
    t.boolean "active",  :default => true
    t.integer "game_id"
  end

  add_index "pieces", ["game_id"], :name => "index_pieces_on_game_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin"
  end

end
