# frozen_string_literal: true

# QR 起動の録音セッション。将来の Resident 紐付けに置き換え可能な user 参照
class RecordingSession < ApplicationRecord
  STATUSES = %w[open processing completed failed].freeze

  belongs_to :user
  has_many :media_assets, dependent: :destroy
  has_one :transcript, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }
  validates :started_at, presence: true

  def as_api_json
    {
      id: id,
      status: status,
      started_at: started_at,
      ended_at: ended_at,
      user_id: user_id
    }
  end
end
