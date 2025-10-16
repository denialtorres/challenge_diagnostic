puts "🌱 Starting to seed the database..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  Session.destroy_all
  User.destroy_all
end

# Create test employees
puts "👥 Creating employees..."

# Create the original 3 test employees for consistent testing
user1 = Employee.find_or_create_by!(email_address: "john@example.com") do |employee|
  employee.password = "password123"
  employee.first_name = "John"
  employee.last_name = "Doe"
  employee.phone_number = "5512345678"
  employee.international_code = "MX"
  employee.date_of_birth = Date.new(1990, 1, 15)
end

user2 = Employee.find_or_create_by!(email_address: "jane@example.com") do |employee|
  employee.password = "password123"
  employee.first_name = "Jane"
  employee.last_name = "Smith"
  employee.phone_number = "2125551234"
  employee.international_code = "US"
  employee.date_of_birth = Date.new(1988, 6, 20)
end

user3 = Employee.find_or_create_by!(email_address: "admin@example.com") do |employee|
  employee.password = "adminpassword"
  employee.first_name = "Admin"
  employee.last_name = "User"
  employee.phone_number = "6045559999"
  employee.international_code = "CA"
  employee.date_of_birth = Date.new(1985, 12, 1)
end

# Create 97 additional employees to reach 100 total
puts "👥 Creating 97 additional employees with realistic data..."

# Sample data arrays
first_names = [
  "Michael", "Christopher", "Jessica", "Matthew", "Ashley", "Jennifer", "Joshua", "Amanda", "Daniel", "David",
  "James", "Robert", "John", "Joseph", "Andrew", "Ryan", "Brandon", "Jason", "Justin", "Sarah",
  "William", "Jonathan", "Stephanie", "Brian", "Nicole", "Nicholas", "Anthony", "Heather", "Eric", "Elizabeth",
  "Adam", "Megan", "Melissa", "Kevin", "Steven", "Thomas", "Timothy", "Christina", "Kyle", "Rachel",
  "Laura", "Lauren", "Amber", "Brittany", "Danielle", "Richard", "Kimberly", "Jeffrey", "Amy", "Crystal",
  "Michelle", "Tiffany", "Jeremy", "Benjamin", "Mark", "Emily", "Aaron", "Charles", "Rebecca", "Jacob",
  "Stephen", "Patrick", "Sean", "Erin", "Zachary", "Jamie", "Kelly", "Samantha", "Nathan", "Sara",
  "Dustin", "Paul", "Angela", "Tyler", "Scott", "Andrea", "Gregory", "Erica", "Brandy", "Walter",
  "Joshua", "Emma", "Noah", "Olivia", "Liam", "Ava", "Mason", "Sophia", "Lucas", "Isabella",
  "Alexander", "Mia", "Ethan", "Charlotte", "Jacob", "Abigail", "Michael", "Emily", "Benjamin"
]

last_names = [
  "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
  "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
  "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
  "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
  "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts",
  "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz", "Edwards", "Collins", "Reyes",
  "Stewart", "Morris", "Morales", "Murphy", "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper",
  "Peterson", "Bailey", "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Richardson",
  "Watson", "Brooks", "Chavez", "Wood", "James", "Bennett", "Gray", "Mendoza", "Ruiz", "Hughes",
  "Price", "Alvarez", "Castillo", "Sanders", "Patel", "Myers", "Long", "Ross", "Foster", "Jimenez"
]

international_codes = [ "MX", "US", "CA" ]
# Valid 3-digit area codes for each country
mx_area_codes = [ "551", "552", "553", "554", "555", "556", "557", "558", "559", "810", "811", "812", "330", "331", "332" ]
us_area_codes = [ "212", "213", "312", "415", "617", "202", "305", "404", "713", "214", "646", "917", "718", "347", "929" ]
ca_area_codes = [ "604", "416", "514", "403", "780", "902", "506", "709", "867", "250", "778", "236", "647", "437", "365" ]

97.times do |i|
  first_name = first_names.sample
  last_name = last_names.sample
  email = "#{first_name.downcase}.#{last_name.downcase}#{i + 1}@example.com"

  international_code = international_codes.sample

  # Generate valid 10-digit phone number: 3-digit area code + 7-digit number
  phone_number = case international_code
  when "MX"
    area_code = mx_area_codes.sample
    "#{area_code}#{rand(1000000..9999999)}"
  when "US"
    area_code = us_area_codes.sample
    "#{area_code}#{rand(1000000..9999999)}"
  when "CA"
    area_code = ca_area_codes.sample
    "#{area_code}#{rand(1000000..9999999)}"
  end

  # Generate a random date of birth between 1970 and 2000
  year = rand(1970..2000)
  month = rand(1..12)
  # Ensure valid day for the month
  max_day = case month
  when 2
    year % 4 == 0 ? 29 : 28
  when 4, 6, 9, 11
    30
  else
    31
  end
  day = rand(1..max_day)

  date_of_birth = Date.new(year, month, day)

  Employee.find_or_create_by!(email_address: email) do |employee|
    employee.password = "password123"
    employee.first_name = first_name
    employee.last_name = last_name
    employee.phone_number = phone_number
    employee.international_code = international_code
    employee.date_of_birth = date_of_birth
  end
end

puts "✅ Created #{User.count} employees"

# Create some test sessions for the original users
puts "🔑 Creating test sessions..."

session1 = user1.sessions.find_or_create_by!(user_agent: "Test Browser", ip_address: "127.0.0.1")
session2 = user2.sessions.find_or_create_by!(user_agent: "Mobile App", ip_address: "127.0.0.1")

puts "✅ Created #{Session.count} sessions"

puts "\n🎉 Database seeded successfully!"
puts "\n📋 Test Data Summary:"
puts "=" * 50
puts "Total Employees: #{User.count}"
puts ""
puts "Main Test Employees:"
[ user1, user2, user3 ].each do |user|
  puts "  📧 #{user.email_address} (ID: #{user.id}) - #{user.type}"
  puts "     Name: #{user.first_name} #{user.last_name}"
  puts "     Phone: #{user.phone_number}"
  puts "     DOB: #{user.date_of_birth}"
  puts "     Password: password123" if user.email_address.include?("john") || user.email_address.include?("jane")
  puts "     Password: adminpassword" if user.email_address.include?("admin")
  puts ""
end

puts "Additional Employees: #{User.count - 3} employees with realistic data"
puts "  - All have password: password123"
puts "  - Email format: firstname.lastname[number]@example.com"
puts "  - Countries: MX, US, CA with appropriate phone numbers"

puts "\nSessions:"
Session.all.each do |session|
  puts "  🔑 Token: #{session.token}"
  puts "     User: #{session.user.email_address}"
  puts "     User Agent: #{session.user_agent}"
end

puts "\n🚀 Ready to test your API endpoints with pagination!"
puts "\n📖 Usage Examples:"
puts "=" * 50
puts "1. Create a session (Login):"
puts "   POST http://localhost:3000/v1/auth/login"
puts "   Content-Type: application/json"
puts "   Body: {"
puts '     "email_address": "john@example.com",'
puts '     "password": "password123"'
puts "   }"
puts ""
puts "2. Get paginated employees (first 10):"
puts "   GET http://localhost:3000/v1/employees"
puts "   Authorization: Bearer YOUR_TOKEN_HERE"
puts ""
puts "3. Get next page of employees:"
puts "   GET http://localhost:3000/v1/employees?page_token=YOUR_PAGE_TOKEN"
puts "   Authorization: Bearer YOUR_TOKEN_HERE"
puts ""
puts "4. Delete a session (Logout):"
puts "   DELETE http://localhost:3000/v1/auth/logout"
puts "   Authorization: Bearer YOUR_TOKEN_HERE"
puts ""
puts "5. Test with different employees:"
puts "   - john@example.com / password123 (John Doe)"
puts "   - jane@example.com / password123 (Jane Smith)"
puts "   - admin@example.com / adminpassword (Admin User)"
puts "   - Any generated employee email / password123"
puts ""
puts "💡 With 100 employees and 10 per page, you'll have 10 pages to test pagination!"
