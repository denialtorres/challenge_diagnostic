class EmployeeSerializer
  include JSONAPI::Serializer

  attributes :id, :email_address, :first_name, :last_name, :phone_number, :created_at, :updated_at

  attribute :type do |employee|
    employee.type
  end
end
