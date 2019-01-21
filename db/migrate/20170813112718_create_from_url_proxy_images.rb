class CreateFromUrlProxyImages < ActiveRecord::Migration
  def change
    create_table :from_url_proxy_images do |t|
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
