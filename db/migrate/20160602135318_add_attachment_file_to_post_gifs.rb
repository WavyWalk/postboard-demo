class AddAttachmentFileToPostGifs < ActiveRecord::Migration
  def self.up
    change_table :post_gifs do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :post_gifs, :file
  end
end
