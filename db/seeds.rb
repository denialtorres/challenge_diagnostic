
puts "🌱 Starting to seed the database..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  Session.destroy_all
  User.destroy_all
end

# Create test users
puts "👥 Creating users..."

user1 = User.find_or_create_by!(email_address: "john@example.com") do |user|
  user.password = "password123"
end

user2 = User.find_or_create_by!(email_address: "jane@example.com") do |user|
  user.password = "password123"
end

user3 = User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.password = "adminpassword"
end

puts "✅ Created #{User.count} users"

# Create some test sessions
puts "🔑 Creating test sessions..."

session1 = user1.sessions.find_or_create_by!(user_agent: "Test Browser", ip_address: "127.0.0.1")
session2 = user2.sessions.find_or_create_by!(user_agent: "Mobile App", ip_address: "127.0.0.1")

puts "✅ Created #{Session.count} sessions"

puts "\n🎉 Database seeded successfully!"
puts "\n📋 Test Data Summary:"
puts "=" * 50
puts "Users:"
User.all.each do |user|
  puts "  📧 #{user.email_address} (ID: #{user.id})"
  puts "     Password: password123" if user.email_address.include?("john") || user.email_address.include?("jane")
  puts "     Password: adminpassword" if user.email_address.include?("admin")
end

puts "\nSessions:"
Session.all.each do |session|
  puts "  🔑 Token: #{session.token}"
  puts "     User: #{session.user.email_address}"
  puts "     User Agent: #{session.user_agent}"
end

puts "\n🚀 Ready to test your API endpoints!"
puts "\n📖 Usage Examples:"
puts "=" * 50
puts "1. Create a session (Login):"
puts "   POST http://localhost:3000/v1/session"
puts "   Content-Type: application/json"
puts "   Body: {"
puts '     "email_address": "john@example.com",'
puts '     "password": "password123"'
puts "   }"
puts ""
puts "2. Delete a session (Logout):"
puts "   DELETE http://localhost:3000/v1/session"
puts "   Authorization: Bearer YOUR_TOKEN_HERE"
puts ""
puts "3. Test with different users:"
puts "   - john@example.com / password123"
puts "   - jane@example.com / password123"
puts "   - admin@example.com / adminpassword"
