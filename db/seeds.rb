# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

adminCredentials = UserCredential.where({email: "admin@doe.com"}).limit(1).first

if adminCredentials == nil
  credentials = UserCredential.new({email: "admin@doe.com", password_digest: UserCredential.auth_service.digest("123456")})
  admin = User.new({name: "Admin"})
  admin.user_credential = credentials
  admin.role_service.add_role("admin", "staff")
  admin.user_karma = UserKarma.new({count: 0})
  admin.registered = true
  admin.save!
end

PostType.populate_post_types