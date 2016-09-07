require 'rails_helper'

describe PasswordResetsMailer do
  before(:all) do
    @user = User.create(email: "user@magicforum.com", password: "123456", username: "user", role: 0)
  end

  describe "send email" do
    it "should send email" do
      @user.update(password_reset_token: "resettoken", password_reset_at: DateTime.now)
      mail = PasswordResetsMailer.password_reset_mail(@user)
      expect(mail.to[0]).to eql(@user.email)
      expect(mail.body.include?("http://localhost:3000/password_resets/#{@user.password_reset_token}/edit")).to eql(true)
    end
  end
end
