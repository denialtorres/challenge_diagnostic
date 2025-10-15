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
        employee = build(:employee, email_address: email)
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
        employee = build(:employee, email_address: email)
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
