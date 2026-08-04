# frozen_string_literal: true

# 回顧録（本文＋PDF）。STEP A では User 直結
class Memoir < ApplicationRecord
  STATUSES = %w[pending generating ready failed].freeze

  belongs_to :user
  has_one_attached :pdf

  validates :status, inclusion: { in: STATUSES }

  def as_api_json
    {
      id: id,
      status: status,
      title: title,
      body: body,
      pdf_attached: pdf.attached?
    }
  end
end
