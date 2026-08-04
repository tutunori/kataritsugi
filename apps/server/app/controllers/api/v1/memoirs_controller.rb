# frozen_string_literal: true

module Api
  module V1
    class MemoirsController < Api::BaseController
      def index
        memoirs = current_user.memoirs.order(created_at: :desc)
        render json: { ok: true, memoirs: memoirs.map(&:as_api_json) }
      end

      def create
        memoir = current_user.memoirs.create!(status: "pending", title: "回顧録")
        # STEP A: 即時完了を優先（後でキューに戻してよい）
        GenerateMemoirPdfJob.perform_now(memoir.id)
        render json: { ok: true, memoir: memoir.as_api_json }, status: :created
      end

      def show
        memoir = current_user.memoirs.find(params[:id])
        render json: { ok: true, memoir: memoir.as_api_json }
      end
    end
  end
end
