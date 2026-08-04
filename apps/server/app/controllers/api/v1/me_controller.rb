# frozen_string_literal: true

module Api
  module V1
    class MeController < Api::BaseController
      def show
        render json: { ok: true, user: current_user.as_api_user }
      end

      def update
        if current_user.update(basic_info: params[:basic_info].to_s)
          render json: { ok: true, user: current_user.as_api_user }
        else
          render json: { ok: false, error: "invalid", message: current_user.errors.full_messages.join(", ") },
                 status: :unprocessable_entity
        end
      end
    end
  end
end
