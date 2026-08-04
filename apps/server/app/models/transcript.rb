# frozen_string_literal: true

# 文字起こしと AI 補正結果
class Transcript < ApplicationRecord
  STATUSES = %w[pending transcribing correcting ready failed].freeze

  belongs_to :recording_session

  validates :status, inclusion: { in: STATUSES }

  def as_api_json
    {
      id: id,
      status: status,
      raw_text: raw_text,
      corrected_text: corrected_text,
      recording_session_id: recording_session_id
    }
  end
end
