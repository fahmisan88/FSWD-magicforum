require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  before(:all) do
    @admin= User.create(email: "admin@magicforum.com", password: "123456", username: "admin", role: 2)
    @moderator= User.create(email: "moderator@magicforum.com", password: "123456", username: "moderator", role: 1)
    @user= User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0)
    @unauthorized_user = User.create(email: "nouser@magicforum.com", password:"123456", username: "nouser", role:0)
    @topic= Topic.create(title: "Testing Topic", description: "To test the topic via rspec testing")
    @post= Post.create(title: "Testing Post", body: "To test the post via rspec testing", user_id: @user.id, topic_id: @topic.id)
    @comment= Comment.create(body: "New Comment", user_id: @moderator.id, post_id: @post.id)
    @vote= Vote.create(value: 1, comment_id:@comment.id, user_id:@admin.id)
  end

  describe "upvote" do
    it "should deny upvote if not login" do
      params = { vote: {value: 1}, comment_id:@comment }
      post :upvote, params: params, xhr: true
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should upvote if user is logged in eventhough not owner of comment" do
      params = { vote: {value: 1}, comment_id:@comment }
      post :upvote, params: params, xhr: true, session: { id: @user.id }
      vote = Vote.find_by(value: 1)
      expect(Vote.count).to eql(2)
      expect(vote.value).to eql(1)
      expect(flash[:alert]).to eql("You like this comment!")
    end
  end

  describe "downvote" do
    it "should deny downvote if not login" do
      params = { vote: {value: -1}, comment_id:@comment }
      post :downvote, params: params, xhr: true
      expect(flash[:danger]).to eql("You need to login first")
    end

    it "should downvote back after upvote from the same user" do
      params = {vote: {value: -1}, comment_id:@comment }
      post :downvote, params: params, xhr: true, session: { id: @admin.id }
      vote = Vote.find_by(user_id:@admin.id)
      expect(vote.value).to eql(-1)
      expect(Vote.count).to eql(1)
      expect(flash[:alert]).to eql("You dislike this comment!")
    end

    it "should downvote if user is logged in eventhough not owner of comment" do
      params = {vote: {value: -1}, comment_id: @comment }
      post :downvote, params: params, xhr: true, session: { id: @user.id }
      vote = Vote.find_by(value: -1)
      expect(vote.value).to eql(-1)
      expect(Vote.count).to eql(2)
      expect(flash[:alert]).to eql("You dislike this comment!")
    end
  end
end
