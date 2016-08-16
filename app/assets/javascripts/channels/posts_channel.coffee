postsChannelFunctions = () ->

  checkMe = (comment_id, username) ->
    unless $('meta[name=admin]').length > 0 || $("meta[user=#{username}]").length > 0
      $("#comment_#{comment_id} .control-panel").remove()
    $("#comment_#{comment_id}").removeClass("hidden")

  if $('.commentsection').length > 0

    App.posts_channel = App.cable.subscriptions.create {
      channel: "PostsChannel"
    },
    connected: () ->

    disconnected: () ->

    received: (data) ->
      
      if $('.commentsection').data().id
        $('#comments').append(data.partial)
      checkMe(data.comment.id, data.username)

$(document).on 'turbolinks:load', postsChannelFunctions
