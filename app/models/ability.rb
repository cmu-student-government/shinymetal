# Used to determine the routes that a known user or a guest can access.
# Only used for authorization in controllers, not views.
class Ability
  include CanCan::Ability

  # Define which routes the user can access.
  #
  # @param user [User, nil] User object, or nil if the user is not logged in.
  def initialize(user)
    # Remember for future reference if the user was a guest.
    logged_in = !user.nil?

    # User is passed in from application controller, but is nil if it was a guest.
    user ||= User.new

    # Everyone can read the not-so-static pages.
    can :read, Page

    # Approver-only rights.
    if user.role? :is_approver
      can :approve_key, UserKey do |key|
        key.at_stage? :awaiting_confirmation
      end

      can :undo_approve_key, UserKey do |key|
        key.at_stage? :awaiting_confirmation
      end

    end
    #End of approver rights

    # Admin-only rights.
    # Admin can do everything EXCEPT view other requester's keys
    # when they have not yet been submitted.
    if user.role? :admin

      # Admin panel
      can :manage, :home

      # User
      # Admins should not be able to create or destroy users, since these routes don't exist.
      # Users should be created automatically when logging in via shibboleth.
      can :manage, User

      # Filter
      # Admin can do anything they want to with filters.
      can :manage, Filter

      # Pages
      can :manage, Page

      # Questions
      can :manage, Question

      # Orgs
      can :manage, Organization

      # Whitelist
      # Admin can do anything they want to with whitelists.
      can :manage, Whitelist

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

      # Admins can destroy keys at any time
      can :destroy, UserKey

    end
    # End Admin rights

    # Staff rights
    # These are common rights among staff so that any staffmember can read most information.
    if user.role? :is_staff

      # Users
      # Can read (show, index) any user
      can :read, User

      # All staff can search on User
      can :search, User

      # Filters
      # Can read (show, index) filters
      can :read, Filter

      # Orgs
      # Can read (show, index) orgs
      can :read, Organization

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

      # All staff can search on UserKey
      can :search, UserKey

    end
    # End is_staff rights

    # Requester and Key Owner rights
    # These rights are universally available to anyone who is logged in
    if logged_in

      # Can see the 'home#index' page (distinct from the guest 'welcome' page)
      can :index, :home

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
      # Can discard a new application
      can :destroy, UserKey do |key|
        user.owns?(key) and key.at_stage? :awaiting_submission
      end
      # Can create a new key for themselves
      can :create, UserKey

      # Custom express app
      can :express, UserKey
      can :create_express, UserKey

      # No universal Filter key rights exist for requesters.

    #End basic logged_in rights.
    end

  ##End def initialize.
  end
end
