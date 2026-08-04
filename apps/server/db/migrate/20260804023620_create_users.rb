# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.text :basic_info
      t.string :qr_token, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :qr_token, unique: true
  end
end
