class VotesController < ApplicationController
respond_to :js
before_action :authenticate!
before_action :check_find_or_create

  def upvote
    voting(1)
    VoteBroadcastJob.perform_later("upvote",@comment)
    flash.now[:alert] = "You like this comment!"
  end

  def downvote
    voting(-1)
    VoteBroadcastJob.perform_later("downvote",@comment)
    flash.now[:alert] = "You dislike this comment!"
  end

  # def cancelvote
  #   voting(0)
  #   VoteBroadcastJob.perform_later("cancelvote",@comment)
  #   flash.now[:alert] = "You have cancel voting this comment"

  private

  def check_find_or_create
    @vote = current_user.votes.find_or_create_by(comment_id: params[:comment_id])
    @comment = Comment.find_by(id: params[:comment_id])
  end

  def voting(value)
      @vote.update(value: value)
  end

end
