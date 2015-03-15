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
  
  # Use these routes to set a key as submitted, filtered, etc
  patch 'user_keys/:id/set_as_submitted' => 'user_keys#set_as_submitted', as: :set_as_submitted
  patch 'user_keys/:id/set_as_filtered' => 'user_keys#set_as_filtered', as: :set_as_filtered
  patch 'user_keys/:id/set_as_confirmed' => 'user_keys#set_as_confirmed', as: :set_as_confirmed

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
