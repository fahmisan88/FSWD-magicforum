require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before(:all) do
    @admin= User.create(email: "admin@magicforum.com", password: "123456", username: "admin", role: 2)
    @moderator= User.create(email: "moderator@magicforum.com", password: "123456", username: "moderator", role: 1)
    @user= User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0)
  end

  describe "Login session" do
    it "should deny if incorrect user params" do
      params = {user: {email: "admin@magicforum.com", password:"abcdef"} }
      post :create, params: params
      expect(flash[:danger]).to eql("Error logging in")
    end
    it "should logged in if correct user params" do
      params = {user: {email: "user@magicforum.com", password:"123456"} }
      post :create, params: params
      expect(session[:id]).to eql(@user.id)
      expect(flash[:success]).to eql("Welcome back user")
    end
  end

  describe "Logout session" do
    it "should end session when user log out" do
      params = {id: @admin.id}
      delete :destroy, params: params, session: { id: @admin.id }
      expect(session[:id]).to be_nil
      expect(flash[:success]).to eql("You've been logged out")
    end
  end
end
