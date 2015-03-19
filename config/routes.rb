Rails.application.routes.draw do
  get 'home/index'

  resources :filters

  resources :user_keys

  resources :users
  
  resources :sessions
  
  # Authentication routes
  get 'logout' => 'sessions#destroy', as: :logout
  get 'login' => 'sessions#new', as: :login
  
  # User key comment adding
  patch 'user_keys/:id/add_comment' => 'user_keys#add_comment', as: :add_comment
  patch 'user_keys/:id/delete_comment/:comment_id' => 'user_keys#delete_comment', as: :delete_comment
  
  # Use these routes to set a key as submitted, filtered, etc
  patch 'user_keys/:id/set_as_submitted' => 'user_keys#set_as_submitted', as: :set_as_submitted
  patch 'user_keys/:id/set_as_filtered' => 'user_keys#set_as_filtered', as: :set_as_filtered
  patch 'user_keys/:id/set_as_confirmed' => 'user_keys#set_as_confirmed', as: :set_as_confirmed

  # Approve the key as current user
  patch 'user_keys/:id/approve_key' => 'user_keys#approve_key', as: :approve_key
  patch 'user_keys/:id/undo_approve_key' => 'user_keys#undo_approve_key', as: :undo_approve_key

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  root 'home#index'

  # routes for the api and respective versions
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users
    end
  
    # in the future, we can simply do
    # namespace :v2 do
    #   resources :user
    # end
    # etc. for each endpoint
  end


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
end
