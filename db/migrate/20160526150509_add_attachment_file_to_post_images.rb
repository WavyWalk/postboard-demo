class AddAttachmentFileToPostImages < ActiveRecord::Migration
  def self.up
    change_table :post_images do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :post_images, :file
  end
end
