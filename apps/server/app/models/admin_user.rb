# frozen_string_literal: true

# 管理画面の運用者。一般ユーザ（User）とは別認証（tanagrid と同型）
class AdminUser < ApplicationRecord
  ROLES = %w[admin].freeze

  has_secure_password

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :role, inclusion: { in: ROLES }
end
