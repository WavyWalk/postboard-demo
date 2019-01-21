class AddSubtitlesToPostGifs < ActiveRecord::Migration
  def change
    add_column :post_gifs, :subtitles, :text
  end
end
