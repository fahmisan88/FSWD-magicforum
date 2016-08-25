class PostsController < ApplicationController
respond_to :js
before_action :authenticate!, only: [:create, :edit, :update, :new, :destroy]

  def index
    @topic = Topic.includes(:posts).friendly.find(params[:topic_id])
    @posts = @topic.posts.order("created_at ASC")
    @post = Post.new
  end

  # def new
  #   @topic = Topic.find_by(id: params[:topic_id])
  #   @post = Post.new
  # end

  def create
    @topic = Topic.friendly.find(params[:topic_id])
    @post = current_user.posts.build(post_params.merge(topic_id: @topic.id))
    @new_post = Post.new



    if @post.save
      flash.now[:success] = "You have created a new post!"
      # redirect_to topic_posts_path(@topic)
    else
      flash.now[:danger] = @post.errors.full_messages
      # render new_topic_post_path(@topic)
    end
  end

  def edit
    @post = Post.find_by(id: params[:id])
    @topic = @post.topic
    authorize @post
  end

  def update
    @topic = Topic.find_by(id: params[:topic_id])
    @post = Post.find_by(id: params[:id])
    authorize @post

    if @post.update(post_params)
      redirect_to topic_posts_path(@topic)
    else
      redirect_to edit_topic_post_path(@topic, @post)
    end
  end

  def destroy
    @post = Post.find_by(id: params[:id])
    authorize @post
    @topic = @post.topic
    if @post.destroy
      redirect_to topic_posts_path(@topic)
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :image)
  end
end
