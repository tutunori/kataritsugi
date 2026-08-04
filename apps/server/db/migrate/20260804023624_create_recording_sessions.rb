# frozen_string_literal: true

class CreateRecordingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :recording_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "open"
      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.timestamps
    end
    add_index :recording_sessions, :status
  end
end
