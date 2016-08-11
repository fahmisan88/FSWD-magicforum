class PostPolicy < ApplicationPolicy

  def edit?
    user.present? && record.user == user || user_has_power?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def user_has_power?
    user.admin? || user.moderator?
  end
end
