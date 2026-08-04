# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    helper_method :current_admin_user

    private

    def current_admin_user
      return @current_admin_user if defined?(@current_admin_user)

      @current_admin_user = AdminUser.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
    end

    def require_admin!
      return if current_admin_user

      redirect_to admin_login_path, alert: "管理者ログインが必要です"
    end
  end
end
