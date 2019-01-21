class PostTestStat < Model
  register

  attributes :from, :to, :count

  has_one :post_test, class_name: 'PostTest'

end