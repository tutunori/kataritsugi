# frozen_string_literal: true

# Web マイページ（基本情報はテキスト 1 つ）
class MypagesController < ApplicationController
  before_action :require_login!

  def show
  end

  def update
    if current_user.update(basic_info: params[:basic_info].to_s)
      redirect_to mypage_path, notice: "保存しました"
    else
      flash.now[:alert] = current_user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end
end
