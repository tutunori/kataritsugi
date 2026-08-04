# frozen_string_literal: true

# セッションに紐づく音声／写真
class MediaAsset < ApplicationRecord
  KINDS = %w[audio photo].freeze

  belongs_to :recording_session
  has_one_attached :file

  validates :kind, inclusion: { in: KINDS }

  def as_api_json
    {
      id: id,
      kind: kind,
      recording_session_id: recording_session_id,
      attached: file.attached?
    }
  end
end
