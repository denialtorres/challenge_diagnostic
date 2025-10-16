class PaginatedEmployeesSerializer
  include JSONAPI::Serializer

  attributes :page_info, :employees

  set_id -> { nil }

  attribute :page_info do |object|
    {
      page_records: object.records.size,
      next_page_token: object.next_token,
      previous_page_token: object.prev_token
    }
  end

  attribute :employees do |object|
    EmployeeSerializer.new(object.records).serializable_hash[:data]
  end
end
