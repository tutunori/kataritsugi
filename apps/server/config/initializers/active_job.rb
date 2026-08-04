# Active Job は開発では非同期インプロセス実行
Rails.application.configure do
  config.active_job.queue_adapter = :async
end
