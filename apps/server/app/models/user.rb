# frozen_string_literal: true

# STEP A: 家族／施設／話者を同一にした一般ユーザ（AdminUser とは別）
class User < ApplicationRecord
  has_secure_password

  has_many :api_tokens, dependent: :destroy
  has_many :recording_sessions, dependent: :destroy
  has_many :memoirs, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :qr_token, presence: true, uniqueness: true

  before_validation :ensure_qr_token, on: :create

  def as_api_user
    {
      id: id,
      email: email,
      basic_info: basic_info,
      qr_token: qr_token
    }
  end

  private

  def ensure_qr_token
    self.qr_token ||= SecureRandom.urlsafe_base64(24)
  end
end
