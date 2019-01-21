class UserRole < Model

  register

  attributes :id, :name

  ADMIN = 'admin'
  GUEST = 'guest'
  NO_NAME = 'no_name'
  STAFF  = 'staff'
  NO_EMAIL = 'no_email'
  EMAIL_PROVIDED = 'email_provided'
  NAME_PROVIDED = 'name_provided'
  NO_EMAIL_OR_PASSWORD = 'no_e_or_p'

end
