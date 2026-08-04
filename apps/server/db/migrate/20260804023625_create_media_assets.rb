# frozen_string_literal: true

class CreateMediaAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :media_assets do |t|
      t.references :recording_session, null: false, foreign_key: true
      t.string :kind, null: false

      t.timestamps
    end
    add_index :media_assets, :kind
  end
end
