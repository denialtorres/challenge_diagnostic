FactoryBot.define do
  factory :employee do
    sequence(:email_address) { |n| "employee#{n}@example.com" }
    password { "password123" }
    first_name { "John" }
    last_name { "Doe" }
    date_of_birth { Date.new(1990, 1, 15) }
    phone_number { "5512345678" }
    international_code { "MX" }

    trait :with_different_name do
      first_name { "Jane" }
      last_name { "Smith" }
      date_of_birth { Date.new(1988, 6, 20) }
      phone_number { "6045551234" }
      international_code { "CA" }
    end

    trait :admin do
      first_name { "Admin" }
      last_name { "User" }
      email_address { "admin@example.com" }
      password { "adminpassword" }
      date_of_birth { Date.new(1985, 12, 1) }
      phone_number { "2125551234" }
      international_code { "US" }
    end

    trait :us_phone do
      phone_number { "2125551234" }
      international_code { "US" }
    end

    trait :ar_phone do
      phone_number { "1112345678" }
      international_code { "AR" }
    end
  end
end
