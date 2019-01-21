class AddAttachmentFileToFromUrlProxyImages < ActiveRecord::Migration
  def self.up
    change_table :from_url_proxy_images do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :from_url_proxy_images, :file
  end
end
