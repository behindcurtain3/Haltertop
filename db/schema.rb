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

ActiveRecord::Schema.define(:version => 20110531100534) do

  create_table "boards", :force => true do |t|
    t.integer  "game_id"
    t.string   "fen"
    t.string   "algebraic"
    t.integer  "move_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boards", ["game_id"], :name => "index_boards_on_game_id"

  create_table "games", :force => true do |t|
    t.integer  "black_id"
    t.integer  "white_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result"
  end

  add_index "games", ["black_id"], :name => "index_games_on_black_id"
  add_index "games", ["white_id"], :name => "index_games_on_white_id"

  create_table "moves", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.string   "capture"
    t.string   "promoted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notation"
    t.string   "castle"
    t.string   "check"
    t.string   "enpassant"
    t.string   "from"
    t.string   "to"
    t.string   "piece"
  end

  add_index "moves", ["game_id"], :name => "index_moves_on_game_id"
  add_index "moves", ["user_id"], :name => "index_moves_on_user_id"

  create_table "pieces", :force => true do |t|
    t.string  "name"
    t.string  "color"
    t.integer "col"
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
