# frozen_string_literal: true

# Bearer トークン（平文は発行時のみ。DB には SHA-256 digest）
class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :device_id, presence: true

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def self.find_by_raw_token(raw_token)
    return nil if raw_token.blank?

    find_by(token_digest: digest(raw_token))
  end

  def self.issue_for!(user, device_id)
    device = device_id.to_s.strip
    raise ArgumentError, "device_id is required" if device.blank?

    where(user_id: user.id, device_id: device).delete_all

    raw = "kt_#{SecureRandom.urlsafe_base64(32)}"
    create!(
      user: user,
      device_id: device,
      token_digest: digest(raw),
      last_used_at: Time.current
    )
    raw
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end
end
