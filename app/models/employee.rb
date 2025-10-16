class Employee < User
  attr_accessor :international_code

  validates :email_address, presence: true
  validate :email_format
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :phone_number, presence: true

  # Phone validation after formatting
  validates_plausible_phone :phone_number,
                            message: "is not a valid phone number",
                            country_code: ->(employee) { employee.international_code || "MX" }

  validates :international_code, inclusion: {
    in: YAML.load_file(Rails.root.join("config", "country_dialing_codes.yml")).keys,
    message: "is not a supported country"
  }, allow_blank: true

  # Format phone before validation
  before_validation :format_phone_number

  private

  def email_format
    unless email_address =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      errors.add(:email_address, "is not a valid email address")
    end
  end

  def format_phone_number
    return if phone_number.blank?

    # Use international_code if present, otherwise default to MX
    country = international_code.presence || "MX"

    formatter = PhoneFormatter.new
    formatted = formatter.format(phone_number, country_code: country)

    # Only update if formatting was successful
    self.phone_number = formatted if formatted
  end
end
