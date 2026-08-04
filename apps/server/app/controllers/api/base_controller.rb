# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    before_action :authenticate_user!

    attr_reader :current_user, :current_api_token

    private

    def authenticate_user!
      raw = bearer_token
      token = ApiToken.find_by_raw_token(raw)
      unless token
        return render json: { ok: false, error: "unauthorized" }, status: :unauthorized
      end

      token.touch_last_used!
      @current_api_token = token
      @current_user = token.user
    end

    def bearer_token
      header = request.headers["Authorization"].to_s
      header.delete_prefix("Bearer ").strip
    end

    def skip_authentication
      # no-op hook for subclasses that skip before_action
    end
  end
end
