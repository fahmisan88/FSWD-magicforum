class CommentsController < ApplicationController
respond_to :js
before_action :authenticate!, only: [:create, :edit, :update, :new, :destroy]

  def index
    @post = Post.includes(:comments).find_by(id: params[:post_id])
    @topic = @post.topic
    @comments =@post.comments.order("created_at ASC").page params[:page]
    @comment = Comment.new
  end

  # def new
  #   @post = Post.find_by(id: params[:post_id])
  #   @topic = @post.topic
  #   @comment = Comment.new
  # end

  def create
    @post = Post.find_by(id: params[:post_id])
    # @topic = @post.topic
    @comment = current_user.comments.build(comment_params.merge(post_id: params[:post_id]))
    @new_comment = Comment.new

    if @comment.save
      CommentBroadcastJob.perform_later("create", @comment)
      flash.now[:success] = "You have created a new comment!"
      # redirect_to topic_post_comments_path(@topic, @post)
    else
      flash.now[:danger] = @comment.errors.full_messages
      # redirect_to new_topic_post_comment_path(@topic, @post)
    end
  end

  def edit
    @post = Post.find_by(id: params[:post_id])
    @topic = @post.topic
    @comment = Comment.find_by(id: params[:id])
    authorize @comment
  end

  def update
    @post = Post.find_by(id: params[:post_id])
    @topic = @post.topic
    @comment = Comment.find_by(id: params[:id])
    authorize @comment


    if @comment.update(comment_params)
      CommentBroadcastJob.perform_later("update", @comment)
      flash.now[:success] = "You have edited a comment!"
      # redirect_to topic_post_comments_path(@topic,@post)
    else
      flash.now[:danger] = @comment.errors.full_messages
      # redirect_to edit_topic_post_comment_path(@topic,@post, @comment)
    end
  end

  def destroy
    @post = Post.find_by(id: params[:post_id])
    @comment = Comment.find_by(id: params[:id])
    authorize = @comment

    if @comment.destroy
      CommentBroadcastJob.perform_now("destroy", @comment)
      flash.now[:success] = "You deleted a comment!"
      # redirect_to topic_post_comments_path(@post)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :image)
  end

end
