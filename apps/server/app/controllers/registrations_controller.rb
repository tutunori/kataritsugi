# frozen_string_literal: true

class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(email: params[:email], password: params[:password])
    if @user.save
      session[:user_id] = @user.id
      redirect_to mypage_path, notice: "登録しました"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end
end
