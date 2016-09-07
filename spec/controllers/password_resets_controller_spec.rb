require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  before(:all) do
    @admin= User.create(email: "admin@magicforum.com", password: "123456", username: "admin", role: 2)
    @moderator= User.create(email: "moderator@magicforum.com", password: "123456", username: "moderator", role: 1, password_reset_token: SecureRandom.urlsafe_base64, password_reset_at: DateTime.now-2)
    @user= User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0,password_reset_token: SecureRandom.urlsafe_base64, password_reset_at: DateTime.now )
  end

  describe "render index" do
    it "should render index" do
      get :new
      expect(subject).to render_template(:new)
    end
  end

  describe "render password reset mailer" do
    it "should render reset when registered user click reset password" do
      params = {reset: {email: "admin@magicforum.com"} }
      post :create, params: params
      expect(flash[:success]).to eql("We've sent you instructions on how to reset your password")
    end

    it "should deny for unregistered user" do
      params = {reset: {email: "macarena@magicforum.com"} }
      post :create, params: params
      expect(flash[:danger]).to eql("User does not exist")
    end
  end

  describe "edit new password page" do
    it "should render if token is equal to user id" do
      params = {id: @admin.id}
      get :edit, params: params
      expect(subject).to render_template(:edit)
    end
  end

  describe "update new password" do
    it "should update new password if token still active" do
      params = { id: @user.password_reset_token, user: {password: "newpassword" } }
      patch :update, params: params
      @user.reload
      expect(flash[:success]).to eql("Password updated, you may log in now")
    end

    it "should deny update if token is expired" do
      params = { id: @moderator.password_reset_token, user: {password: "newpassword" } }
      patch :update, params: params
      @moderator.reload
      expect(flash[:danger]).to eql("Error, token is invalid or has expired")
    end
  end

end
