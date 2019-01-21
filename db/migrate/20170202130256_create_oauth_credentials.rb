class CreateOauthCredentials < ActiveRecord::Migration
  def change
    create_table :oauth_credentials do |t|
      t.text :provider
      t.text :uid
      t.string :seraized_schema_from_provider
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :oauth_credentials, :provider
    add_index :oauth_credentials, :uid
  end
end
