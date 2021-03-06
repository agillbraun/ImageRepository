# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_23_203412) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "images", id: :string, force: :cascade do |t|
    t.string "file_name"
    t.integer "file_size"
    t.string "mime_type"
    t.integer "width"
    t.integer "height"
    t.string "orientation"
    t.string "title"
    t.string "description"
    t.string "secret"
    t.boolean "private"
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "image_id", null: false
    t.string "kind"
    t.string "value"
    t.integer "count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["image_id"], name: "index_tags_on_image_id"
  end

end
