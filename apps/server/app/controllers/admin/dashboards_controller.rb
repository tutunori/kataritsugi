# frozen_string_literal: true

module Admin
  class DashboardsController < BaseController
    def show
      @users_count = User.count
      @sessions_count = RecordingSession.count
      @memoirs_count = Memoir.count
    end
  end
end
