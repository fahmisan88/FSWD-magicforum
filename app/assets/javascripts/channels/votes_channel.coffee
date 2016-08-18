votesChannelFunctions = () ->

  upvoteComment = (data) ->
    if $('.commentsection').data().id
      $("#comment_#{data.comment.id}").after(data.partial).remove()


  downvoteComment = (data) ->
    if $('.commentsection').data().id
      $("#comment_#{data.comment.id}").after(data.partial).remove()
    


  if $('<your-comments-index-element>').length > 0
    App.votes_channel = App.cable.subscriptions.create {
      channel: "VotesChannel"
    },
    connected: () ->

    disconnected: () ->

    received: (data) ->
      switch data.type
        when "upvote" then upvoteComment(data)
        when "downvote" then downvoteComment(data)

$(document).on 'turbolinks:load', votesChannelFunctions
