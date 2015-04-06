class Ability
  include CanCan::Ability

  def initialize(user)
    # Remember that the user is a guest
    logged_in = !user.nil?

    # User is passed in from application controller, this is if the user is a guest
    user ||= User.new

    # Authorize user keys, users, filters, and
    # the comments in User Keys.

    # Approver rights
    if user.role? :is_approver
      can :approve_key, UserKey do |key|
        key.at_stage? :awaiting_confirmation
      end

      can :undo_approve_key, UserKey do |key|
        key.at_stage? :awaiting_confirmation
      end

    end
    #End of approver rights

    # Admin-only rights
    # Admin can do everything EXCEPT view other requester's keys,
    # which have not yet been submitted.
    if user.role? :admin

      # User
      # Admins should not be able to create or destroy users, since these routes don't exist.
      # Users should be created automatically when logging in via shibboleth.
      can :manage, User

      # Filter
      # Admin can do anything they want to with filters.
      can :manage, Filter

      # UserKey
      # Comments cant be changed at awaiting_sub stage
      can :update, UserKey do |key|
        !(key.at_stage? :awaiting_submission)
      end
      # Only allow filter completion when at awaiting_filters stage
      can :set_as_filtered, UserKey do |key|
        key.at_stage? :awaiting_filters
      end
      # Only allow confirm when at awaiting_confirmation stage
      can :set_as_confirmed, UserKey do |key|
        key.at_stage? :awaiting_confirmation
      end
      # Only allow reset when awaiting confirmation or awaiting filters
      can :set_as_reset, UserKey do |key|
        key.at_stage? :awaiting_filters or key.at_stage? :awaiting_confirmation
      end
      # Admins can destroy keys
      can :destroy, UserKey

      # Admins can search on UserKey
      can :search, UserKey

    end
    # End Admin rights

    # Staff rights
    # These are common rights among staff so that any staffmember can read most information.
    if user.role? :is_staff

      # Users
      # Can read (show, index) any user
      can :read, User

      # Filters
      # Can read (show, index) filters
      can :read, Filter

      # User Keys
      # Can read (show, index) any submitted UserKeys
      can :read, UserKey do |key|
        !(key.at_stage? :awaiting_submission)
      end
      # Staffmembers can comment on any unsubmitted key
      # Edge case: If a staffmember has their own key pending, they still can't comment on it.
      can :add_comment, UserKey do |key|
        !(key.at_stage? :awaiting_submission)
      end
      can :delete_comment, UserKey do |key|
        !(key.at_stage? :awaiting_submission)
      end

    end
    # End is_staff rights

    # Requester and Key Owner rights
    # These rights are universally available to anyone who is logged in
    if logged_in

      # Users
      # Can see their own profile
      can :show, User do |accessed_user|
        accessed_user.id == user.id
      end

      # UserKey
      # Can edit their own unsubmitted applications
      can :update, UserKey do |key|
        user.owns?(key) and key.at_stage?(:awaiting_submission)
      end
      # Can see their own user keys
      can :show, UserKey do |key|
        user.owns?(key)
      end
      # Can submit their own keys
      can :set_as_submitted, UserKey do |key|
        user.owns?(key) and key.at_stage?(:awaiting_submission)
      end
      # Can see their own keys
      can :own_user_keys, UserKey do |key|
        user.owns?(key)
      end
      # Can create a new key for themselves
      can :create, UserKey

      # No universal Filter key rights for requesters

    #End basic logged_in rights
    end

  ##End def initialize
  end
end
