# A user, created or retrieved in the controllers when someone logs in via Shibboleth.
class User < ActiveRecord::Base
  # Get the user's name from CMU::Person.
  # This uses the user's andrew ID, which is provided by Shibboleth,
  # so it doesnt' need to be validated here.
  before_save :set_name

  # Relationships
  
  has_many :user_keys

  # Validations
  
  # Four roles exist. Admins can do most everything, requesters can only submit keys
  # and use API functionality. Staff can comment on key applications. Admins and staff who are also
  # approvers must all approve each key application, but only admins can edit access rights, activate
  # or inactivate or delete user keys or users or filters, or
  # release keys to users.
  ROLE_LIST = {"requester" => "Requester",
               "admin" => "Administrator (Approver)",
               "staff_approver" => "Staff (Approver)",
               "staff_not_approver" => "Staff"}

  validates :role, inclusion: { in: ROLE_LIST.keys, message: "is not a recognized role in system" }
   
  # Scopes
  
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :by_andrew, -> { order(:andrew_id) }
  scope :approvers_only, -> { where("role = 'admin' or role = 'staff_approver'") }
  scope :staff_only, ->  { where.not(role: 'requester') }
  scope :requesters_only, ->  { where(role: 'requester') }
  scope :admin, ->  { where(role: 'admin') }

  # Methods
  
  # Display the nice formatted version of the user's role.
  #
  # @return [String] The value of the user's role in the ROLE_LIST hash.
  def display_role
    ROLE_LIST[self.role]
  end
  
  # Display the email address for this user.
  #
  # @return [String] The email address for this user.
  def email
    "#{andrew_id}@andrew.cmu.edu"
  end
  
  # Check whether or not this user created the given user key.
  #
  # @param user_key [UserKey] Any user key object.
  # @return [Boolean] True iff the user key belongs to this user.
  def owns?(user_key)
    user_key.user.id == self.id
  end

  # Check if the role or role category matches the user's role.
  #
  # @param sym [Symbol] One of these categories: is_staff, is_approver, requester, or admin.
  # @return [Boolean] True if the user has a role that matches the category.
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

  # Print the name of the user.
  #
  # @param proper [Boolean] Whether or not name should be printed in proper format.
  # @return [String] The user's name in the proper format.
  def name(proper=true)
    proper ? "#{first_name} #{last_name}" : "#{last_name}, #{first_name}"
  end

  # Class method to search for users based on the given terms, up to the given max.
  #
  # @param term [String] The search term, searched for in the user's name or andrew id. 
  # @param max [Integer] The maximum number of results in the collection.
  # @return [ActiveRecord::Association] The users, capped at the max, that match the term.
  def self.search(term, max=5)
    term = "%#{term.to_s.downcase}%"
    andrew = 'LOWER(andrew_id)'
    first = 'LOWER(first_name)'
    last = 'LOWER(last_name)'
    full = "LOWER(#{connection.concat('first_name', '\' \'', 'last_name')})"
    where("#{andrew} LIKE ? OR #{first} LIKE ? OR #{last} LIKE ? OR #{full} LIKE ?", term, term, term, term).limit(max)
  end 
  
  private
  # Set the person's name automatically as part of a callback. Relies on the CMU::Person gem to fetch
  # the data using the person's andrew id.
  def set_name
    person = CMU::Person.find(andrew_id)
    if !person.nil?   
      self.first_name = person.first_name
      self.last_name = person.last_name
    end
  end
end
