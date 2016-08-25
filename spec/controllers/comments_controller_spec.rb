require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  before(:all) do
    @admin= User.create(email: "admin@magicforum.com", password: "123456", username: "admin", role: 2)
    @moderator= User.create(email: "moderator@magicforum.com", password: "123456", username: "moderator", role: 1)
    @user= User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0)
    @unauthorized_user = User.create(email: "nouser@magicforum.com", password:"123456", username: "nouser", role:0)
    @topic= Topic.create(title: "Testing Topic", description: "To test the topic via rspec testing")
    @post= Post.create(title: "Testing Post", body: "To test the post via rspec testing", user_id: @user.id, topic_id: @topic.id)
    @comment= Comment.create(body: "New Comment", user_id: @user.id)
  end

  describe "render index" do
    it "should render index" do

      params= {topic_id: @topic.id, post_id: @post.id}
      get :index, params: params
      expect(Comment.count).to eql (1)
      expect(subject).to render_template(:index)
    end
  end

  describe "create comment" do
    it "should deny if not login" do

      params = { comment: {body: "test comment"}, topic_id:@topic.id, post_id:@post.id}
      post :create, params: params, xhr: true
      expect(flash[:danger]).to eql("You need to login first")
    end


    it "should create if user" do

      params = { comment: {body: "test comment"}, topic_id:@topic.id, post_id:@post.id}
      post :create, params: params, xhr: true, session: { id: @user.id }
      comment = Comment.find_by(body: "test comment")
      expect(Comment.count).to eql(2)
      expect(comment.body).to eql("test comment")
      expect(flash[:success]).to eql("You have created a new comment!")
    end

    it "should create if admin" do

      params = { comment: {body: "test comment"}, topic_id:@topic.id, post_id:@post.id}
      post :create, params: params, xhr: true, session: { id: @admin.id }
      comment = Comment.find_by(body: "test comment")
      expect(Comment.count).to eql(2)
      expect(comment.body).to eql("test comment")
      expect(flash[:success]).to eql("You have created a new comment!")
    end

    it "should create if moderator" do

      params = { comment: {body: "test comment"}, topic_id:@topic.id, post_id:@post.id}
      post :create, params: params, xhr: true, session: { id: @moderator.id }
      comment = Comment.find_by(body: "test comment")
      expect(Comment.count).to eql(2)
      expect(comment.body).to eql("test comment")
      expect(flash[:success]).to eql("You have created a new comment!")
    end
  end

  describe "edit comment" do

    it "should deny if not logged in" do

      params = { id: @comment, topic_id:@topic.id, post_id:@post.id}
      get :edit, params: params, xhr: true

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should deny if user unauthorized" do

      params = { id: @comment, topic_id:@topic.id, post_id:@post.id}
      get :edit, params: params, xhr: true, session: { id: @unauthorized_user.id }

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should render edit if user is logged in and is the owner" do

      params = { id: @comment, topic_id:@topic.id, post_id:@post.id}
      get :edit, params: params, xhr: true, session: { id: @user.id }

      current_user = subject.send(:current_user)
      expect(subject).to render_template(:edit)
      expect(current_user).to be_present
    end
  end

  describe "update comment" do

    it "should render update post if user is logged in and the owner" do

      params = { id: @comment, comment: { body: "updated comment" },topic_id:@topic.id, post_id:@post.id }
      patch :update, params: params, xhr: true, session: { id: @user.id }

      @user.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("user@magicforum.com")
      expect(current_user.username).to eql("user")
      comment = Comment.find_by(body: "updated comment")
      expect(comment.body).to eql("updated comment")
    end

    it "should render update post if moderator is logged in eventhough not the owner" do

      params = { id: @comment, comment: { body: "updated comment" },topic_id:@topic.id, post_id:@post.id }
      patch :update, params: params, xhr: true, session: { id: @moderator.id }
      @moderator.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("moderator@magicforum.com")
      expect(current_user.username).to eql("moderator")
      comment = Comment.find_by(body: "updated comment")
      expect(comment.body).to eql("updated comment")
    end


  it "should render update post if admin is logged eventhough not the owner" do

    params = { id: @comment, comment: { body: "updated comment"},topic_id:@topic.id, post_id:@post.id }
    patch :update, params: params, xhr:true, session: { id: @admin.id }

    @admin.reload
    current_user = subject.send(:current_user).reload

    expect(current_user.email).to eql("admin@magicforum.com")
    expect(current_user.username).to eql("admin")
    comment = Comment.find_by(body: "updated comment")
    expect(comment.body).to eql("updated comment")
    end
  end

  describe "delete comment" do

    it "should render destroy if user is logged in and owner" do

      params = { id: @comment, topic_id:@topic.id, post_id:@post.id }
      delete :destroy, params: params, xhr:true, session: { id: @user.id }

      @user.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("user@magicforum.com")
      expect(current_user.username).to eql("user")
      comment = Comment.find_by(id: @comment.id)
      expect(Comment.count).to eql(0)
      expect(comment).to be_nil
    end

    it "should render destroy if admin is logged in eventhough not owner" do

      params = { id: @comment, topic_id:@topic.id, post_id:@post.id }
      delete :destroy, params: params, xhr:true, session: { id: @admin.id }

      @admin.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("admin@magicforum.com")
      expect(current_user.username).to eql("admin")
      comment = Comment.find_by(id: @comment.id)
      expect(Comment.count).to eql(0)
      expect(comment).to be_nil
    end
  end
end
