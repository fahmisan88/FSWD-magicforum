class CommentsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "comments_channel"
    logger.add_tags 'ActionCable', "User connected to comments channel"
  end

  def unsubscribed
  end
end
