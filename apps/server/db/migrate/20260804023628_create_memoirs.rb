# frozen_string_literal: true

class CreateMemoirs < ActiveRecord::Migration[8.1]
  def change
    create_table :memoirs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :title
      t.text :body

      t.timestamps
    end
    add_index :memoirs, :status
  end
end
