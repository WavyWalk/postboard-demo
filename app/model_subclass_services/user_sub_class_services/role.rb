class UserSubClassServices::Role





  def initialize(owner)
      @owner = owner
  end






  def add_role(*role_names)

    owner_roles = @owner.user_roles.map(&:name)

    role_names.each do |role_name|

      if !owner_roles.include?(role_name)

        @owner.user_roles << ::UserRole.find_or_create_by(name: role_name)

      end

    end

  end





  def has_roles?(*role_names)

    roles = ::UserRole.joins(:user_role_links).where('user_role_links.user_id = ?', @owner.id).where('user_roles.name in (?)', role_names).map(&:name)

    not_found_roles = role_names - roles

    if not_found_roles.empty?
      return true
    else
      return false
    end


  end





  def destroy_user_role_link_to_role_with_name(*role_names)

    UserRoleLink.joins(:user_role).where('user_roles.name in (?)', role_names).where('user_role_links.user_id = ?', @owner.id).destroy_all

  end




end
