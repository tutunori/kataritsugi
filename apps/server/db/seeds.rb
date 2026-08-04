# frozen_string_literal: true

AdminUser.find_or_create_by!(email: "admin@example.com") do |admin|
  admin.password = "password123"
  admin.role = "admin"
end

User.find_or_create_by!(email: "demo@example.com") do |user|
  user.password = "password123"
  user.basic_info = "デモユーザ（家族＝施設＝話者）"
end

puts "Seeded admin@example.com / demo@example.com (password: password123)"
