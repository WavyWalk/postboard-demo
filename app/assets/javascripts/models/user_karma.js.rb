class UserKarma < Model

  register

  attributes :id, :count

  has_one :user, class_name: 'User'

end