# frozen_string_literal: true

# 文字起こし文の AI 補正（STEP A はスタブ）
class CorrectTranscriptJob < ApplicationJob
  queue_as :default

  def perform(transcript_id)
    transcript = Transcript.find(transcript_id)
    transcript.update!(status: "correcting")

    corrected = transcript.raw_text.to_s.sub("スタブ文字起こし", "スタブ補正済み文字起こし")
    transcript.update!(corrected_text: corrected, status: "ready")
    transcript.recording_session.update!(status: "completed")
  rescue StandardError => e
    transcript&.update(status: "failed")
    raise e
  end
end
