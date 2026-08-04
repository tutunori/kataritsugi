# frozen_string_literal: true

module Api
  module V1
    # QR トークンでセッション開始・一覧
    class RecordingSessionsController < Api::BaseController
      def index
        sessions = current_user.recording_sessions.order(started_at: :desc).limit(50)
        render json: { ok: true, recording_sessions: sessions.map(&:as_api_json) }
      end

      def show
        session_record = current_user.recording_sessions.find(params[:id])
        render json: {
          ok: true,
          recording_session: session_record.as_api_json,
          transcript: session_record.transcript&.as_api_json,
          media_assets: session_record.media_assets.map(&:as_api_json)
        }
      end

      # POST /api/v1/recording_sessions { qr_token }
      def create
        target = User.find_by(qr_token: params[:qr_token].to_s)
        unless target
          return render json: { ok: false, error: "invalid_qr" }, status: :not_found
        end

        # STEP A: 話者＝収集者＝同一 User。自分の QR 以外は拒否して誤認を防ぐ
        unless target.id == current_user.id
          return render json: { ok: false, error: "qr_mismatch" }, status: :forbidden
        end

        session_record = current_user.recording_sessions.create!(
          status: "open",
          started_at: Time.current
        )
        render json: { ok: true, recording_session: session_record.as_api_json }, status: :created
      end

      # POST /api/v1/recording_sessions/:id/complete
      def complete
        session_record = current_user.recording_sessions.find(params[:id])
        session_record.update!(status: "processing", ended_at: Time.current)
        transcript = session_record.transcript || session_record.create_transcript!(status: "pending")
        TranscribeSessionJob.perform_later(transcript.id) # 補正までジョブ内で同期完了
        render json: { ok: true, recording_session: session_record.as_api_json }
      end
    end
  end
end
