class TopicPolicy < ApplicationPolicy

  def new?
    user.present? && (user.admin?||user.moderator?)
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end
end
