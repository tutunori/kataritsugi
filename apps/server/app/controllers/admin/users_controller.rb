# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @users = User.order(created_at: :desc)
    end

    def show
      @user = User.find(params[:id])
    end
  end
end
