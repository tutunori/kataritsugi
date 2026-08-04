# frozen_string_literal: true

module Api
  module V1
    class MediaAssetsController < Api::BaseController
      # POST /api/v1/recording_sessions/:recording_session_id/media_assets
      def create
        session_record = current_user.recording_sessions.find(params[:recording_session_id])
        kind = params[:kind].to_s
        unless MediaAsset::KINDS.include?(kind)
          return render json: { ok: false, error: "invalid_kind" }, status: :unprocessable_entity
        end
        unless params[:file].present?
          return render json: { ok: false, error: "file_required" }, status: :unprocessable_entity
        end

        asset = session_record.media_assets.create!(kind: kind)
        asset.file.attach(params[:file])
        render json: { ok: true, media_asset: asset.as_api_json }, status: :created
      end
    end
  end
end
