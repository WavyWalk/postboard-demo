# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170828104703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.text     "name"
    t.text     "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "day_karma_events", force: :cascade do |t|
    t.integer  "day_karma_stat_id"
    t.integer  "up_count",           default: 0
    t.integer  "down_count",         default: 0
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "event_type"
    t.integer  "user_id"
    t.text     "source_text"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "parent_source_id"
    t.string   "parent_source_type"
  end

  add_index "day_karma_events", ["day_karma_stat_id"], name: "index_day_karma_events_on_day_karma_stat_id", using: :btree
  add_index "day_karma_events", ["parent_source_type", "parent_source_id"], name: "dke_on_ps", using: :btree
  add_index "day_karma_events", ["source_type", "source_id"], name: "index_day_karma_events_on_source_type_and_source_id", using: :btree
  add_index "day_karma_events", ["user_id"], name: "index_day_karma_events_on_user_id", using: :btree

  create_table "day_karma_stats", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "up_count",   default: 0
    t.integer  "down_count", default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "day_karma_stats", ["user_id"], name: "index_day_karma_stats_on_user_id", using: :btree

  create_table "discussion_message_karma_transactions", force: :cascade do |t|
    t.integer  "discussion_message_karma_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.string   "cancel_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "discussion_message_karma_transactions", ["discussion_message_karma_id"], name: "dmkt_on_dmk", using: :btree
  add_index "discussion_message_karma_transactions", ["user_id"], name: "index_discussion_message_karma_transactions_on_user_id", using: :btree

  create_table "discussion_message_karmas", force: :cascade do |t|
    t.integer  "discussion_message_id"
    t.integer  "count"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "discussion_message_karmas", ["discussion_message_id"], name: "index_discussion_message_karmas_on_discussion_message_id", using: :btree

  create_table "discussion_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "discussion_message_id"
    t.integer  "discussion_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "discussion_messages", ["discussion_id"], name: "index_discussion_messages_on_discussion_id", using: :btree
  add_index "discussion_messages", ["discussion_message_id"], name: "index_discussion_messages_on_discussion_message_id", using: :btree
  add_index "discussion_messages", ["user_id"], name: "index_discussion_messages_on_user_id", using: :btree

  create_table "discussions", force: :cascade do |t|
    t.integer  "discussable_id"
    t.string   "discussable_type"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "messages_count",   default: 0
  end

  add_index "discussions", ["discussable_type", "discussable_id"], name: "index_discussions_on_discussable_type_and_discussable_id", using: :btree

  create_table "from_url_proxy_images", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "from_url_proxy_images", ["user_id"], name: "index_from_url_proxy_images_on_user_id", using: :btree

  create_table "geographic_places", force: :cascade do |t|
    t.text     "name"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "geographic_places", ["country_id"], name: "index_geographic_places_on_country_id", using: :btree

  create_table "media_stories", force: :cascade do |t|
    t.text     "title"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "media_stories", ["user_id"], name: "index_media_stories_on_user_id", using: :btree

  create_table "media_story_nodes", force: :cascade do |t|
    t.integer  "media_story_id"
    t.integer  "media_id"
    t.string   "media_type"
    t.text     "annotation"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "media_story_nodes", ["media_story_id"], name: "index_media_story_nodes_on_media_story_id", using: :btree
  add_index "media_story_nodes", ["media_type", "media_id"], name: "index_media_story_nodes_on_media_type_and_media_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "read"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "oauth_credentials", force: :cascade do |t|
    t.text     "provider"
    t.text     "uid"
    t.string   "seraized_schema_from_provider"
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "oauth_credentials", ["provider"], name: "index_oauth_credentials_on_provider", using: :btree
  add_index "oauth_credentials", ["uid"], name: "index_oauth_credentials_on_uid", using: :btree
  add_index "oauth_credentials", ["user_id"], name: "index_oauth_credentials_on_user_id", using: :btree

  create_table "p_t_personalities", force: :cascade do |t|
    t.text     "title"
    t.integer  "media_id"
    t.string   "media_type"
    t.integer  "post_test_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "p_t_personalities", ["media_type", "media_id"], name: "index_p_t_personalities_on_media_type_and_media_id", using: :btree
  add_index "p_t_personalities", ["post_test_id"], name: "index_p_t_personalities_on_post_test_id", using: :btree

  create_table "personality_scales", force: :cascade do |t|
    t.integer  "scale"
    t.integer  "p_t_personality_id"
    t.integer  "test_answer_variant_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "personality_scales", ["p_t_personality_id"], name: "index_personality_scales_on_p_t_personality_id", using: :btree
  add_index "personality_scales", ["test_answer_variant_id"], name: "index_personality_scales_on_test_answer_variant_id", using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "post_gifs", force: :cascade do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "orphaned"
    t.text     "dimensions"
    t.integer  "user_id"
    t.text     "subtitles"
  end

  add_index "post_gifs", ["user_id"], name: "index_post_gifs_on_user_id", using: :btree

  create_table "post_images", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "orphaned"
    t.text     "dimensions"
    t.text     "file_url"
    t.text     "source_name"
    t.text     "source_link"
    t.text     "alt_text"
  end

  add_index "post_images", ["user_id"], name: "index_post_images_on_user_id", using: :btree

  create_table "post_karma_transactions", force: :cascade do |t|
    t.integer  "post_karma_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "cancel_type"
  end

  add_index "post_karma_transactions", ["post_karma_id"], name: "index_post_karma_transactions_on_post_karma_id", using: :btree
  add_index "post_karma_transactions", ["user_id"], name: "index_post_karma_transactions_on_user_id", using: :btree

  create_table "post_karmas", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "hot_since"
    t.integer  "count_u"
    t.integer  "count_d"
  end

  add_index "post_karmas", ["post_id"], name: "index_post_karmas_on_post_id", using: :btree

  create_table "post_nodes", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "node_id"
    t.string   "node_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "post_nodes", ["node_type", "node_id"], name: "index_post_nodes_on_node_type_and_node_id", using: :btree
  add_index "post_nodes", ["post_id"], name: "index_post_nodes_on_post_id", using: :btree

  create_table "post_tag_links", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "post_tag_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "post_tag_links", ["post_id"], name: "index_post_tag_links_on_post_id", using: :btree
  add_index "post_tag_links", ["post_tag_id"], name: "index_post_tag_links_on_post_tag_id", using: :btree

  create_table "post_tags", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "special"
  end

  add_index "post_tags", ["name"], name: "index_post_tags_on_name", using: :btree
  add_index "post_tags", ["special"], name: "index_post_tags_on_special", using: :btree

  create_table "post_test_gradations", force: :cascade do |t|
    t.integer  "from"
    t.integer  "to"
    t.integer  "post_test_id"
    t.integer  "content_id"
    t.string   "content_type"
    t.text     "message"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "post_test_gradations", ["content_type", "content_id"], name: "index_post_test_gradations_on_content_type_and_content_id", using: :btree
  add_index "post_test_gradations", ["post_test_id"], name: "index_post_test_gradations_on_post_test_id", using: :btree

  create_table "post_test_stats", force: :cascade do |t|
    t.integer  "from"
    t.integer  "to"
    t.integer  "count"
    t.integer  "post_test_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "post_test_stats", ["post_test_id"], name: "index_post_test_stats_on_post_test_id", using: :btree

  create_table "post_tests", force: :cascade do |t|
    t.integer "thumbnail_id"
    t.text    "s_thumbnail"
    t.text    "s_questions"
    t.integer "user_id"
    t.boolean "orphaned"
    t.text    "title"
    t.text    "test_type"
    t.text    "s_gradations"
    t.boolean "is_personality"
  end

  add_index "post_tests", ["thumbnail_id"], name: "index_post_tests_on_thumbnail_id", using: :btree
  add_index "post_tests", ["user_id"], name: "index_post_tests_on_user_id", using: :btree

  create_table "post_texts", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "post_thumbs", force: :cascade do |t|
    t.integer  "node_id"
    t.string   "node_type"
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "post_thumbs", ["node_type", "node_id"], name: "index_post_thumbs_on_node_type_and_node_id", using: :btree
  add_index "post_thumbs", ["post_id"], name: "index_post_thumbs_on_post_id", using: :btree

  create_table "post_tsvs", force: :cascade do |t|
    t.string   "content"
    t.integer  "post_id"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.tsvector "tsv_content"
    t.text     "tsv_options"
    t.string   "tsv_weight",      limit: 1
  end

  add_index "post_tsvs", ["post_id"], name: "index_post_tsvs_on_post_id", using: :btree
  add_index "post_tsvs", ["searchable_type", "searchable_id"], name: "index_post_tsvs_on_searchable_type_and_searchable_id", using: :btree
  add_index "post_tsvs", ["tsv_content"], name: "index_post_tsvs_on_tsv_content", using: :gin

  create_table "post_type_links", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "post_type_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "post_type_links", ["post_id"], name: "index_post_type_links_on_post_id", using: :btree
  add_index "post_type_links", ["post_type_id"], name: "index_post_type_links_on_post_type_id", using: :btree

  create_table "post_types", force: :cascade do |t|
    t.string   "name"
    t.string   "alt_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "post_vote_polls", force: :cascade do |t|
    t.text     "question"
    t.text     "s_options"
    t.integer  "count"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "orphaned"
    t.integer  "m_content_id"
    t.string   "m_content_type"
    t.text     "s_m_content"
  end

  add_index "post_vote_polls", ["m_content_type", "m_content_id"], name: "index_post_vote_polls_on_m_content_type_and_m_content_id", using: :btree
  add_index "post_vote_polls", ["user_id"], name: "index_post_vote_polls_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "content"
    t.boolean  "published"
    t.datetime "published_at"
    t.integer  "author_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "nodes_order"
    t.string   "title"
    t.text     "s_nodes"
  end

  add_index "posts", ["author_id"], name: "index_posts_on_author_id", using: :btree
  add_index "posts", ["published"], name: "index_posts_on_published", using: :btree

  create_table "test_answer_variants", force: :cascade do |t|
    t.integer "test_question_id"
    t.text    "s_content"
    t.integer "content_id"
    t.string  "content_type"
    t.text    "answer_type"
    t.boolean "correct"
    t.text    "text"
    t.text    "on_select_message"
  end

  add_index "test_answer_variants", ["content_type", "content_id"], name: "index_test_answer_variants_on_content_type_and_content_id", using: :btree
  add_index "test_answer_variants", ["test_question_id"], name: "index_test_answer_variants_on_test_question_id", using: :btree

  create_table "test_questions", force: :cascade do |t|
    t.integer "post_test_id"
    t.integer "content_id"
    t.string  "content_type"
    t.text    "s_content"
    t.text    "s_test_answer_variants"
    t.text    "text"
    t.text    "question_type"
    t.integer "on_answered_m_content_id"
    t.string  "on_answered_m_content_type"
    t.text    "s_on_answered_m_content"
    t.text    "on_answered_msg"
  end

  add_index "test_questions", ["content_type", "content_id"], name: "index_test_questions_on_content_type_and_content_id", using: :btree
  add_index "test_questions", ["on_answered_m_content_type", "on_answered_m_content_id"], name: "idx_on_tq_on_answ_cont", using: :btree
  add_index "test_questions", ["post_test_id"], name: "index_test_questions_on_post_test_id", using: :btree

  create_table "user_credentials", force: :cascade do |t|
    t.string   "password_digest"
    t.string   "login_token_digest"
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "remember_token_digest"
    t.text     "name"
    t.boolean  "name_pending"
  end

  add_index "user_credentials", ["user_id"], name: "index_user_credentials_on_user_id", using: :btree

  create_table "user_denormalized_stats", force: :cascade do |t|
    t.integer  "subscribers_count",   default: 0
    t.integer  "comments_count",      default: 0
    t.integer  "karma_count",         default: 0
    t.integer  "posts_count",         default: 0
    t.integer  "subscriptions_count", default: 0
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "user_denormalized_stats", ["user_id"], name: "index_user_denormalized_stats_on_user_id", using: :btree

  create_table "user_karmas", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_karmas", ["user_id"], name: "index_user_karmas_on_user_id", using: :btree

  create_table "user_role_links", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_role_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "user_role_links", ["user_id"], name: "index_user_role_links_on_user_id", using: :btree
  add_index "user_role_links", ["user_role_id"], name: "index_user_role_links_on_user_role_id", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.text "name"
  end

  add_index "user_roles", ["name"], name: "index_user_roles_on_name", using: :btree

  create_table "user_subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "to_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_subscriptions", ["to_user_id"], name: "index_user_subscriptions_on_to_user_id", using: :btree
  add_index "user_subscriptions", ["user_id"], name: "index_user_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.boolean  "registered"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "s_avatar"
    t.text     "name"
  end

  create_table "video_embeds", force: :cascade do |t|
    t.text     "link"
    t.text     "provider"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vote_poll_options", force: :cascade do |t|
    t.integer  "post_vote_poll_id"
    t.text     "content"
    t.integer  "count",             default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "m_content_id"
    t.string   "m_content_type"
  end

  add_index "vote_poll_options", ["m_content_type", "m_content_id"], name: "index_vote_poll_options_on_m_content_type_and_m_content_id", using: :btree
  add_index "vote_poll_options", ["post_vote_poll_id"], name: "index_vote_poll_options_on_post_vote_poll_id", using: :btree

  create_table "vote_poll_transactions", force: :cascade do |t|
    t.integer  "post_vote_poll_id"
    t.integer  "vote_poll_option_id"
    t.integer  "user_id"
    t.boolean  "type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "vote_poll_transactions", ["post_vote_poll_id"], name: "index_vote_poll_transactions_on_post_vote_poll_id", using: :btree
  add_index "vote_poll_transactions", ["user_id"], name: "index_vote_poll_transactions_on_user_id", using: :btree

  add_foreign_key "day_karma_events", "day_karma_stats"
  add_foreign_key "day_karma_events", "users"
  add_foreign_key "day_karma_stats", "users"
  add_foreign_key "discussion_message_karma_transactions", "discussion_message_karmas"
  add_foreign_key "discussion_message_karma_transactions", "users"
  add_foreign_key "discussion_message_karmas", "discussion_messages"
  add_foreign_key "discussion_messages", "discussion_messages"
  add_foreign_key "discussion_messages", "discussions"
  add_foreign_key "discussion_messages", "users"
  add_foreign_key "from_url_proxy_images", "users"
  add_foreign_key "geographic_places", "countries"
  add_foreign_key "media_stories", "users"
  add_foreign_key "media_story_nodes", "media_stories"
  add_foreign_key "notifications", "users"
  add_foreign_key "oauth_credentials", "users"
  add_foreign_key "p_t_personalities", "post_tests"
  add_foreign_key "personality_scales", "p_t_personalities"
  add_foreign_key "personality_scales", "test_answer_variants"
  add_foreign_key "post_gifs", "users"
  add_foreign_key "post_images", "users"
  add_foreign_key "post_karma_transactions", "post_karmas"
  add_foreign_key "post_karma_transactions", "users"
  add_foreign_key "post_karmas", "posts"
  add_foreign_key "post_nodes", "posts"
  add_foreign_key "post_tag_links", "post_tags"
  add_foreign_key "post_tag_links", "posts"
  add_foreign_key "post_test_gradations", "post_tests"
  add_foreign_key "post_test_stats", "post_tests"
  add_foreign_key "post_tests", "users"
  add_foreign_key "post_thumbs", "posts"
  add_foreign_key "post_tsvs", "posts"
  add_foreign_key "post_type_links", "post_types"
  add_foreign_key "post_type_links", "posts"
  add_foreign_key "post_vote_polls", "users"
  add_foreign_key "test_answer_variants", "test_questions"
  add_foreign_key "test_questions", "post_tests"
  add_foreign_key "user_credentials", "users"
  add_foreign_key "user_denormalized_stats", "users"
  add_foreign_key "user_karmas", "users"
  add_foreign_key "user_role_links", "user_roles"
  add_foreign_key "user_role_links", "users"
  add_foreign_key "user_subscriptions", "users"
  add_foreign_key "user_subscriptions", "users", column: "to_user_id"
  add_foreign_key "vote_poll_options", "post_vote_polls"
  add_foreign_key "vote_poll_transactions", "post_vote_polls"
  add_foreign_key "vote_poll_transactions", "users"
end
