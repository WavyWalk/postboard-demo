class AddRememberTokenDigestToUserCredentials < ActiveRecord::Migration
  def change
    add_column :user_credentials, :remember_token_digest, :string
  end
end
