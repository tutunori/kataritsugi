# frozen_string_literal: true

module Api
  module V1
    class StatusController < Api::BaseController
      skip_before_action :authenticate_user!

      def show
        render json: { ok: true, service: "kataritsugi", step: "A" }
      end
    end
  end
end
