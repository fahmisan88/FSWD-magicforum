class VoteBroadcastJob < ApplicationJob
  queue_as :default

  def perform(type, comment)
    ActionCable.server.broadcast 'votes_channel', type: type, comment: comment, post: comment.post, username: comment.user.username, partial: render_comment_partial(comment)
  end

  private

  def render_comment_partial(comment)
    VotesController.render partial: "comments/comment", locals: { comment: comment, post: comment.post, current_user: comment.user}
  end
end
