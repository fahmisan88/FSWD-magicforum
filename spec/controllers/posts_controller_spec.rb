require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  before(:all) do
    @admin= User.create(email: "admin@magicforum.com", password: "123456", username: "admin", role: 2)
    @moderator= User.create(email: "moderator@magicforum.com", password: "123456", username: "moderator", role: 1)
    @user= User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0)
    @unauthorized_user = User.create(email: "nouser@magicforum.com", password:"123456", username: "nouser", role:0)
    @topic= Topic.create(title: "Testing Topic", description: "To test the topic via rspec testing")
    @post= Post.create(title: "Testing Post", body: "To test the post via rspec testing", user_id: @user.id, topic_id: @topic.id)
  end

  describe "render index" do
    it "should render index" do

      params= {topic_id: @topic.id}
      get :index, params: params
      expect(Post.count).to eql (1)
      expect(subject).to render_template(:index)

    end
  end

  describe "create post" do
    it "should deny if not login" do

      params = { post: {title: "New Rspec Post", body: "Description on Rspec post"}, topic_id:@topic.id}
      post :create, params: params, xhr: true
      expect(flash[:danger]).to eql("You need to login first")
    end


    it "should create if user" do

      params = { post: {title: "New Rspec Post", body: "Description on Rspec post"}, topic_id:@topic.id}
      post :create, params: params, xhr: true, session: { id: @user.id }
      post = Post.find_by(title: "New Rspec Post")
      expect(Post.count).to eql(2)
      expect(post.title).to eql("New Rspec Post")
      expect(post.body).to eql("Description on Rspec post")
      expect(flash[:success]).to eql("You have created a new post!")
    end
    it "should create if admin" do

      params = { post: {title: "New Rspec Post", body: "Description on Rspec post"}, topic_id:@topic.id}
      post :create, params: params, xhr: true, session: { id: @admin.id }
      post = Post.find_by(title: "New Rspec Post")
      expect(Post.count).to eql(2)
      expect(post.title).to eql("New Rspec Post")
      expect(post.body).to eql("Description on Rspec post")
      expect(flash[:success]).to eql("You have created a new post!")
    end

    it "should create if moderator" do

      params = { post: {title: "New Rspec Post", body: "Description on Rspec post"}, topic_id:@topic.id}
      post :create, params: params, xhr: true, session: { id: @moderator.id }
      post = Post.find_by(title: "New Rspec Post")
      expect(Post.count).to eql(2)
      expect(post.title).to eql("New Rspec Post")
      expect(post.body).to eql("Description on Rspec post")
      expect(flash[:success]).to eql("You have created a new post!")
    end
  end

  describe "edit post" do

    it "should deny if not logged in" do

      params = { id: @post, topic_id:@topic.id}
      get :edit, params: params

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should deny if user unauthorized" do

      params = { id: @post, topic_id:@topic.id}
      get :edit, params: params, session: { id: @unauthorized_user.id }

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should render edit if user" do

      params = { id: @post, topic_id:@topic.id }
      get :edit, params: params, session: { id: @user.id }

      current_user = subject.send(:current_user)
      expect(subject).to render_template(:edit)
      expect(current_user).to be_present
    end
  end

  describe "update post" do

    it "should redirect if not logged in" do
      params = { id: @post, post: { title: "updated post", body: "this is a new updated post" },topic_id:@topic.id }
      patch :update, params: params

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should redirect if user unauthorized" do
      params = { id: @post, post: { title: "updated post", body: "this is a new updated post" },topic_id:@topic.id }
      patch :update, params: params, session: { id: @unauthorized_user.id }
      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should render update post if user" do

      params = { id: @post, post: { title: "updated post", post: "this is a new updated post" },topic_id:@topic.id }
      patch :update, params: params, session: { id: @user.id }

      @user.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("user@magicforum.com")
      expect(current_user.username).to eql("user")
      post = Post.find_by(title: "updated post")
      expect(post.title).to eql("updated post")
    end

    it "should render update post if moderator" do

      params = { id: @post, post: { title: "updated post", post: "this is a new updated post" },topic_id:@topic.id }
      patch :update, params: params, session: { id: @moderator.id }

      @moderator.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("moderator@magicforum.com")
      expect(current_user.username).to eql("moderator")
      post = Post.find_by(title: "updated post")
      expect(post.title).to eql("updated post")
    end
  end

  describe "delete post" do

    it "should deny if not logged in" do

      params = { id: @post, topic_id:@topic.id}
      delete :destroy, params: params

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should deny if user unauthorized" do

      params = { id: @post, topic_id:@topic.id}
      delete :destroy, params: params, session: { id: @unauthorized_user.id }

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should render destroy if user" do

      params = { id: @post, topic_id:@topic.id }
      delete :destroy, params: params, session: { id: @user.id }

      @user.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("user@magicforum.com")
      expect(current_user.username).to eql("user")
      post = Post.find_by(id: @post.id)
      expect(Post.count).to eql(0)
      expect(post).to be_nil
    end
  end
end
