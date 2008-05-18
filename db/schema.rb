# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "servers", :force => true do |t|
    t.string   "ip_addr",      :limit => 20, :default => "",   :null => false
    t.string   "port",         :limit => 10, :default => "80", :null => false
    t.string   "result",                     :default => "",   :null => false
    t.string   "transparency", :limit => 20, :default => "",   :null => false
    t.integer  "state",                      :default => 0,    :null => false
    t.integer  "retries",                    :default => 0,    :null => false
    t.string   "duration",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
