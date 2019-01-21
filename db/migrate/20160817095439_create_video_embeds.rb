class CreateVideoEmbeds < ActiveRecord::Migration
  def change
    create_table :video_embeds do |t|
      t.text :link
      t.text :provider

      t.timestamps null: false
    end
  end
end
