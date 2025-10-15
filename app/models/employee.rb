class Employee < User
  validates :email_address, presence: true
  validate :email_format
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :phone_number, presence: true

  private

  def email_format
    unless email_address =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      errors.add(:email_address, 'is not a valid email address')
    end
  end
end
