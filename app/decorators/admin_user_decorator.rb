class AdminUserDecorator < Draper::Decorator
  delegate_all

  def roles_caption
    roles.map(&:name).join ', '
  end
end
