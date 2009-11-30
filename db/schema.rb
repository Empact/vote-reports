# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091130142351) do

  create_table "bill_criteria", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "report_id"
    t.boolean  "support"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bills", :force => true do |t|
    t.text     "title"
    t.string   "bill_type"
    t.string   "opencongress_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "politicians", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "vote_smart_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gov_track_id"
    t.string   "bioguide_id"
    t.string   "congress_office"
    t.string   "congresspedia_url"
    t.string   "crp_id"
    t.string   "district"
    t.string   "email"
    t.string   "event_id"
    t.string   "fax"
    t.string   "fec_id"
    t.string   "gender"
    t.string   "in_office"
    t.string   "middlename"
    t.string   "name_suffix"
    t.string   "nickname"
    t.string   "party"
    t.string   "phone"
    t.string   "senate_class"
    t.string   "state"
    t.string   "title"
    t.string   "twitter_id"
    t.string   "webform"
    t.string   "website"
    t.string   "youtube_url"
  end

  create_table "reports", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "persistence_token"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", :force => true do |t|
    t.integer  "politician_id"
    t.boolean  "vote"
    t.integer  "bill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
