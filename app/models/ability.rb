class Ability
  include CanCan::Ability

  def initialize(user)
    user.roles.each{|role| send role.key}
  end

  def owner
    can :manage, :all
  end

  def staff
    owner
    cannot [:update_role], MerchantUser
  end
end
