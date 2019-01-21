class AsJsonSerializer::Users::Show::GeneralInfo

def initialize(user, post_count)
    @user = user
    @post_count = post_count
  end

  def success

    result = @user.as_json(
      include: [
        :uc_s_name,
        :user_karma
      ]
    )

    result[:post_count] = @post_count

    result

  end

end