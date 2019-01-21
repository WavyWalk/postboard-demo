class CreateUserCredentials < ActiveRecord::Migration
  def change
    create_table :user_credentials do |t|
      t.string :password_digest
      t.string :login_token_digest
      t.string :email
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
