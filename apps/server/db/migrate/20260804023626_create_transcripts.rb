# frozen_string_literal: true

class CreateTranscripts < ActiveRecord::Migration[8.1]
  def change
    create_table :transcripts do |t|
      t.references :recording_session, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.text :raw_text
      t.text :corrected_text

      t.timestamps
    end
    add_index :transcripts, :status
  end
end
