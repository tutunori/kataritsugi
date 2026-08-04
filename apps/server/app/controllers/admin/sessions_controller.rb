# frozen_string_literal: true

module Admin
  class SessionsController < ApplicationController
    def new
    end

    def create
      admin = AdminUser.find_by(email: params[:email].to_s.strip.downcase)
      if admin&.authenticate(params[:password].to_s)
        session[:admin_user_id] = admin.id
        redirect_to admin_root_path, notice: "管理者としてログインしました"
      else
        flash.now[:alert] = "メールまたはパスワードが違います"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:admin_user_id)
      redirect_to admin_login_path, notice: "ログアウトしました"
    end
  end
end
