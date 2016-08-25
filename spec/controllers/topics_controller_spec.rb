require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  before(:all) do
    @admin= User.create(email: "admin@magicforum.com", password: "123456", username: "masteradmin", role: 2)
    @moderator= User.create(email: "moderator@magicforum.com", password: "123456", username: "moderator", role: 1)
    @user= User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0)
    @topic= Topic.create(title: "Testing Topic", description: "To test the topic via rspec testing")
  end

  describe "render index" do
    it "should render index" do
      get :index
      expect(subject).to render_template(:index)
    end
  end

  describe "create topic" do
    it "should deny if not login" do
      params = { topic: {title: "New Rspec Title", description: "Description on Rspec topic"}}
      post :create, params: params, xhr: true
      expect(flash[:danger]).to eql("You need to login first")
    end


    it "should redirect if user unauthorized" do

      params = { topic: {title: "New Rspec Title", description: "Description on Rspec topic"}}
      post :create, params: params, xhr: true, session: { id: @user.id }
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should create if admin" do

      params = { topic: {title: "New Rspec Title", description: "Description on Rspec topic"}}
      post :create, params: params, xhr: true, session: { id: @admin.id }
      topic = Topic.find_by(title: "New Rspec Title")
      expect(Topic.count).to eql(2)
      expect(topic.title).to eql("New Rspec Title")
      expect(topic.description).to eql("Description on Rspec topic")
      expect(flash[:success]).to eql("You've created a new topic.")
    end

    it "should create if moderator" do

      params = { topic: {title: "New Rspec Title", description: "Description on Rspec topic"}}
      post :create, params: params, xhr: true, session: { id: @moderator.id }
      topic = Topic.find_by(title: "New Rspec Title")
      expect(Topic.count).to eql(2)
      expect(topic.title).to eql("New Rspec Title")
      expect(topic.description).to eql("Description on Rspec topic")
      expect(flash[:success]).to eql("You've created a new topic.")
    end
  end

  describe "edit topic" do

    it "should redirect if not logged in" do

      params = { id: @topic }
      get :edit, params: params

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should redirect if user unauthorized" do

      params = { id: @topic }
      get :edit, params: params, session: { id: @user.id }

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should render edit" do

      params = { id: @topic }
      get :edit, params: params, session: { id: @admin.id }

      current_user = subject.send(:current_user)
      expect(subject).to render_template(:edit)
      expect(current_user).to be_present
    end
  end

  describe "update topic" do

    it "should redirect if not logged in" do
      params = { id: @topic, topic: { title: "updated topic", description: "this is a new updated topic" } }
      patch :update, params: params

      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should redirect if user unauthorized" do
      params = { id: @topic, topic: { title: "updated topic", description: "this is a new updated topic" } }
      patch :update, params: params, session: { id: @user.id }
      expect(subject).to redirect_to(root_path)
      expect(flash[:danger]).to eql("You're not authorized")
    end

    it "should update topic" do

      params = { id: @topic, topic: { title: "updated topic", description: "this is a new updated topic" } }
      patch :update, params: params, session: { id: @admin.id }

      @admin.reload
      current_user = subject.send(:current_user).reload

      expect(current_user.email).to eql("admin@magicforum.com")
      expect(current_user.username).to eql("masteradmin")
      topic = Topic.find_by(title: "updated topic")
      expect(topic.title).to eql("updated topic")
    end
  end


end
