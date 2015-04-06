class User < ActiveRecord::Base
  # Relationships
  has_many :user_keys

  # Validations
  ROLE_LIST = ["requester", "admin", "staff_approver", "staff_not_approver"]

  # No need to validate andrew_id; this is not user input
  #validates :andrew_id, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLE_LIST, message: "is not a recognized role in system" }

  scope :alphabetical, -> { order(:andrew_id) }
  scope :approvers_only, -> { where("role = 'admin' or role = 'staff_approver'") }
  scope :staff_only, ->  { where("role <> 'requester'") }
  scope :requesters_only, ->  { where("role == 'requester'") }

  # Methods
  def owns?(user_key)
    return user_key.user.id == self.id
  end

  def role?(sym)
    case sym
      when :is_staff
        return !(self.role == "requester")
      when :is_approver
        return (self.role == "admin" || self.role == "staff_approver")
      when :requester
        return self.role == "requester"
      when :admin
        return self.role == "admin"
    end
  end

  def name(proper=true)
    proper ? "#{first_name} #{last_name}" : "#{last_name}, #{first_name}"
  end

  def self.search(term)
    search_condition = "%#{term}%"
    term = term.to_s.downcase
    andrew = 'LOWER(andrew_id)'
    first = 'LOWER(first_name)'
    last = 'LOWER(last_name)'
    find(:all, conditions: ["#{andrew} LIKE ? OR #{first} LIKE ? OR #{last} LIKE ?", term, term, term])
  end
end
