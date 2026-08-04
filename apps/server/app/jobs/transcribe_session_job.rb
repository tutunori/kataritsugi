# frozen_string_literal: true

# 音声 → 文字起こし（STEP A はスタブ。後で ASR API に差し替え）
class TranscribeSessionJob < ApplicationJob
  queue_as :default

  def perform(transcript_id)
    transcript = Transcript.find(transcript_id)
    transcript.update!(status: "transcribing")

    # TODO: クラウド ASR。当面はプレースホルダテキスト
    raw = "（スタブ文字起こし）セッション ##{transcript.recording_session_id} の音声テキスト"
    transcript.update!(raw_text: raw, status: "correcting")
    # STEP A: ワーカー無しでも通すため同期実行
    CorrectTranscriptJob.perform_now(transcript.id)
  rescue StandardError => e
    transcript&.update(status: "failed")
    raise e
  end
end
