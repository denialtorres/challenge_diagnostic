require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    it 'is valid with all required attributes' do
      employee = build(:employee)
      expect(employee).to be_valid
    end

    it 'requires email_address' do
      employee = build(:employee, email_address: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:email_address]).to include("can't be blank")
    end

    it 'requires first_name' do
      employee = build(:employee, first_name: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:first_name]).to include("can't be blank")
    end

    it 'requires last_name' do
      employee = build(:employee, last_name: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:last_name]).to include("can't be blank")
    end

    it 'requires date_of_birth' do
      employee = build(:employee, date_of_birth: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:date_of_birth]).to include("can't be blank")
    end

    it 'requires phone_number' do
      employee = build(:employee, phone_number: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:phone_number]).to include("can't be blank")
    end

    it 'validates email_address format' do
      employee = build(:employee, email_address: 'plainaddress')
      expect(employee).not_to be_valid
      expect(employee.errors[:email_address]).to include('is not a valid email address')
    end

    it 'accepts valid email_address formats' do
      valid_emails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'first-last@subdomain.example.org'
      ]

      valid_emails.each do |email|
        employee = build(:employee, email_address: email, international_code: "MX")
        expect(employee).to be_valid, "#{email} should be valid"
      end
    end

    it 'rejects invalid email_address formats' do
      invalid_emails = [
        'plainaddress',
        '@missingdomain.com',
        'missing@.com',
        'spaces @domain.com',
        'multiple@@domain.com'
      ]

      invalid_emails.each do |email|
        employee = build(:employee, email_address: email, international_code: "MX")
        expect(employee).not_to be_valid, "#{email} should be invalid"
        expect(employee.errors[:email_address]).to include('is not a valid email address')
      end
    end

    it 'requires password (inherited from User)' do
      employee = build(:employee, password: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:password]).to include("can't be blank")
    end
  end

  describe 'phone number validation' do
    describe 'successful phone validation' do
      it 'accepts valid US phone numbers and formats them' do
        employee = build(:employee, phone_number: "2125551234", international_code: "US")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+1 (212) 555-1234")
      end

      it 'accepts valid Mexican phone numbers and formats them' do
        employee = build(:employee, phone_number: "5512345678", international_code: "MX")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+52 55 1234 5678")
      end

      it 'accepts valid Canadian phone numbers and formats them' do
        employee = build(:employee, phone_number: "6045551234", international_code: "CA")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+1 (604) 555-1234")
      end

      it 'accepts valid Argentine phone numbers and formats them' do
        employee = build(:employee, phone_number: "1112345678", international_code: "AR")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+54 11 1234 5678")
      end

      it 'defaults to MX when no international_code is provided' do
        employee = build(:employee, phone_number: "5512345678", international_code: nil)
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+52 55 1234 5678")
      end
    end

    describe 'failed phone validation' do
      it 'rejects phone numbers that are too short' do
        employee = build(:employee, phone_number: "123", international_code: "US")
        expect(employee).not_to be_valid
        expect(employee.errors[:phone_number]).to include("is not a valid phone number")
      end

      it 'rejects phone numbers with letters' do
        employee = build(:employee, phone_number: "abc123def", international_code: "US")
        expect(employee).not_to be_valid
        expect(employee.errors[:phone_number]).to include("is not a valid phone number")
      end

      it 'rejects phone numbers that are too long' do
        employee = build(:employee, phone_number: "1234567890123456", international_code: "US")
        expect(employee).not_to be_valid
        expect(employee.errors[:phone_number]).to include("is not a valid phone number")
      end

      it 'rejects invalid phone patterns' do
        employee = build(:employee, phone_number: "000000000", international_code: "US")
        expect(employee).not_to be_valid
        expect(employee.errors[:phone_number]).to include("is not a valid phone number")
      end
    end

    describe 'international_code validation' do
      it 'accepts valid country codes' do
        valid_countries = [ 'US', 'CA', 'MX', 'AR', 'BR', 'CO' ]

        valid_countries.each do |country|
          # Use appropriate phone number for each country
          phone = case country
          when 'US', 'CA' then '2125551234'
          when 'MX' then '5512345678'
          when 'AR' then '1112345678'
          when 'BR' then '11987654321'
          when 'CO' then '3001234567'
          else '2125551234'
          end
          employee = build(:employee, phone_number: phone, international_code: country)
          expect(employee).to be_valid, "#{country} should be valid"
        end
      end

      it 'rejects invalid country codes' do
        invalid_countries = [ 'XX', 'ZZ', '123', 'usa', 'UNITED_STATES' ]

        invalid_countries.each do |country|
          employee = build(:employee, phone_number: "2125551234", international_code: country)
          expect(employee).not_to be_valid, "#{country} should be invalid"
          expect(employee.errors[:international_code]).to include("is not a supported country")
        end
      end

      it 'allows blank international_code (defaults to MX)' do
        employee = build(:employee, phone_number: "5512345678", international_code: "")
        expect(employee).to be_valid
      end
    end

    describe 'edge cases' do
      it 'handles phone numbers with dashes and formats correctly' do
        employee = build(:employee, phone_number: "212-555-1234", international_code: "US")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+1 (212) 555-1234")
      end

      it 'handles phone numbers with spaces and formats correctly' do
        employee = build(:employee, phone_number: "212 555 1234", international_code: "US")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+1 (212) 555-1234")
      end

      it 'handles phone numbers with parentheses and formats correctly' do
        employee = build(:employee, phone_number: "(212) 555-1234", international_code: "US")
        expect(employee).to be_valid
        expect(employee.phone_number).to eq("+1 (212) 555-1234")
      end
    end
  end

  describe 'STI inheritance' do
    it 'is a subclass of User' do
      expect(Employee.superclass).to eq(User)
    end

    it 'sets type to Employee when created' do
      employee = create(:employee)
      expect(employee.type).to eq('Employee')
    end

    it 'can be found through User.all' do
      employee = create(:employee)
      expect(User.all).to include(employee)
    end

    it 'can be found through Employee.all' do
      employee = create(:employee)
      expect(Employee.all).to include(employee)
    end
  end

  describe 'associations' do
    it 'has many sessions (inherited from User)' do
      association = Employee.reflect_on_association(:sessions)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'can create sessions' do
      employee = create(:employee)
      session = employee.sessions.create!(user_agent: "Test", ip_address: "127.0.0.1")
      expect(session.user).to eq(employee)
      expect(employee.sessions).to include(session)
    end
  end

  describe 'authentication (inherited from User)' do
    it 'can authenticate with valid credentials' do
      employee = create(:employee, email_address: "test@example.com", password: "password123")
      authenticated_user = User.authenticate_by(email_address: "test@example.com", password: "password123")
      expect(authenticated_user).to eq(employee)
    end

    it 'cannot authenticate with invalid credentials' do
      employee = create(:employee, email_address: "test@example.com", password: "password123")
      authenticated_user = User.authenticate_by(email_address: "test@example.com", password: "wrongpassword")
      expect(authenticated_user).to be_nil
    end
  end
end
