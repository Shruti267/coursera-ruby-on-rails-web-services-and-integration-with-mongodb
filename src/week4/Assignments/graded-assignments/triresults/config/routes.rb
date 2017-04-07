Rails.application.routes.draw do
  root to: "races#index"
  get "pages/index" => "pages#index"
  resources :racers
  resources :races
  resources :racers do
    post "entries" => "racers#create_entry"
  end


  #namespace :api, defaults: {format: 'json'} do
  namespace :api do

  get "races" => "races#index", as: "races"
  get "races/:id" => "races#show", as: "race"
  post "races" => "races#create", as: "race_create"
  put "races/:id" => "races#put", as: "race_put"
  patch "races/:id" => "races#put", as: "race_patch"
  delete "races/:id" => "races#destroy", as: "race_delete"
  get "races/:race_id/results" => "races#results", as: "race_results"
  get "races/:race_id/results/:id" => "races#result", as: "race_result"
  patch "races/:race_id/results/:id" => "races#res_patch", as: "race_res_patch"

  get "racers" => "racers#index", as: "racers"
  get "racers/:id" => "racers#show", as: "racer"
  post "racers" => "racers#create", as: "racer_create"
  get "racers/:racer_id/entries" => "racers#entries", as: "racer_entries"
  get "racers/:racer_id/entries/:id" => "racers#entry", as: "racer_entry"

  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
