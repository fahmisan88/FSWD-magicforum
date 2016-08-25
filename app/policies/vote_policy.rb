class VotePolicy < ApplicationPolicy



  def upvote?
    user.present? || user_has_power?
  end

  def downvote?
    upvote?
  end

  private

  def user_has_power?
    user.admin? || user.moderator?
  end
end
