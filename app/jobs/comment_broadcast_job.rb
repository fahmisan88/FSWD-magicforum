class CommentBroadcastJob < ApplicationJob
  queue_as :default

  def perform(type, comment)
    ActionCable.server.broadcast 'comments_channel', type: type, comment: comment, post: comment.post, username: comment.user.username, partial: render_comment_partial(comment)
  end

  private

  def render_comment_partial(comment)
    CommentsController.render partial: "comments/comment", locals: { comment: comment, post: comment.post, current_user: comment.user, extra_class: "hidden" }
  end
end
