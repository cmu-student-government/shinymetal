Rails.application.routes.draw do
  resources :sessions, only: [:create, :new, :destroy]

  resources :filters, except: [:edit, :update]

  resources :organizations, only: [:show, :index]

  get 'user_keys/search' => 'user_keys#search', as: :user_keys_search # this needs to go before resource :user_keys to override the path
  resources :user_keys

  resources :questions, except: [:show]

  # Users are not deleted, only inactivated.
  # They are not created directly; they are meant to be created automatically via shibboleth login.
  get 'users/search' => 'users#search', as: :users_search # this needs to go before resource :users to override the path
  resources :users, except: [:destroy, :create, :new]

  # Authentication routes
  get 'logout' => 'sessions#logout', as: :logout
  get 'login' => 'sessions#login', as: :login

  # Path to repopulate the organizations look-up table
  patch 'repopulate_organizations' => 'questions#repopulate_organizations', as: :repopulate_organizations

  # Path to add columns from CollegiateLink
  patch 'repopulate_columns' => 'questions#repopulate_columns', as: :repopulate_columns

  # Path to see a user's own keys
  get 'own_user_keys' => 'user_keys#own_user_keys', as: :own_user_keys

  # User key comment adding
  patch 'user_keys/:id/add_comment' => 'user_keys#add_comment', as: :add_comment
  patch 'user_keys/:id/delete_comment/:comment_id' => 'user_keys#delete_comment', as: :delete_comment

  # Use these routes to set a key as submitted, filtered, etc
  patch 'user_keys/:id/set_as_submitted' => 'user_keys#set_as_submitted', as: :set_as_submitted
  patch 'user_keys/:id/set_as_filtered' => 'user_keys#set_as_filtered', as: :set_as_filtered
  patch 'user_keys/:id/set_as_confirmed' => 'user_keys#set_as_confirmed', as: :set_as_confirmed

  # Path to reset a ket back to the awaiting_submission stage
  patch 'user_keys/:id/set_as_reset' => 'user_keys#set_as_reset', as: :set_as_reset

  # Approve the key as current user
  patch 'user_keys/:id/approve_key' => 'user_keys#approve_key', as: :approve_key
  patch 'user_keys/:id/undo_approve_key' => 'user_keys#undo_approve_key', as: :undo_approve_key

  # routes for the api and respective versions
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      get ':endpoint'         => 'api#index', controller: 'api'
    end

    # in the future, we can simply do
    # namespace :v2 do
    #   resources :user
    # end
    # etc. for each endpoint
  end

  root :to => "pages#show", page_url: 'welcome'

  # Home path
  get 'home' => 'home#index', as: :home

  # Catch-all for About, Contact, etc pages
  get ':page_url/edit' => 'pages#edit', as: :edit_page
  get ':page_url' => 'pages#show', as: :page
  patch ':page_url' => 'pages#update'
end
