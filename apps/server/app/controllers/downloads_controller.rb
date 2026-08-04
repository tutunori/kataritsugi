# frozen_string_literal: true

# APK 配布の最小経路（実体は storage/downloads。tanagrid と同型の入口）
class DownloadsController < ApplicationController
  def android
    path = Rails.root.join("storage/downloads/android-latest.apk")
    unless File.exist?(path)
      return render plain: "APK がまだ配置されていません（storage/downloads/android-latest.apk）", status: :not_found
    end

    send_file path, filename: "kataritsugi.apk", type: "application/vnd.android.package-archive"
  end
end
