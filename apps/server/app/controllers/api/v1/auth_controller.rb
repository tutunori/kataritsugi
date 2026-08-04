# frozen_string_literal: true

module Api
  module V1
    class AuthController < Api::BaseController
      skip_before_action :authenticate_user!, only: %i[register login]

      # POST /api/v1/auth/register
      def register
        user = User.new(email: auth_params[:email], password: auth_params[:password])
        if user.save
          token = ApiToken.issue_for!(user, auth_params[:device_id].presence || "web")
          render json: { ok: true, token: token, user: user.as_api_user }, status: :created
        else
          render json: { ok: false, error: "invalid", message: user.errors.full_messages.join(", ") },
                 status: :unprocessable_entity
        end
      rescue ArgumentError => e
        render json: { ok: false, error: "invalid", message: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: auth_params[:email].to_s)
        unless user&.authenticate(auth_params[:password].to_s)
          return render json: { ok: false, error: "invalid_credentials" }, status: :unauthorized
        end

        device_id = auth_params[:device_id].presence || "android"
        token = ApiToken.issue_for!(user, device_id)
        render json: { ok: true, token: token, user: user.as_api_user }
      rescue ArgumentError => e
        render json: { ok: false, error: "invalid", message: e.message }, status: :unprocessable_entity
      end

      # DELETE /api/v1/auth/logout
      def logout
        current_api_token.destroy!
        render json: { ok: true }
      end

      private

      def auth_params
        params.permit(:email, :password, :device_id)
      end
    end
  end
end
