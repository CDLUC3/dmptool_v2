Dmptool2::Application.routes.draw do

 root 'static_pages#home'
 match 'about', to: 'static_pages#about', via: 'get'
 match 'help', to: 'static_pages#help', via: 'get'
 match 'contact', to: 'static_pages#contact', via: 'get'
 match 'logout', to: 'user_sessions#destroy', via: 'get'

  resources :requirements_templates do
    resources :requirements
    member do
      get :toggle_active
      get :template_details
    end
    resources :sample_plans
    resources :additonal_informations
  end

  resources :resource_templates do
    resources :resources
    member do
      get :toggle_active
      get :template_details
    end
  end

  resources :plans
  resources :institutions
  resources :users
  resources :roles

  get 'user_sessions/login', to: 'user_sessions#login', as: 'login'
  post '/auth/:provider/callback', to: 'user_sessions#create'
  get '/auth/failure', to: 'user_sessions#failure'

  get  'requirements_template_information', to: 'requirements_templates#template_information'
  get  'copy_existing_requirements_template', to: 'requirements_templates#copy_existing_template'

  get  'resource_template_information', to: 'resource_templates#template_information'
  get  'copy_existing_resource_template', to: 'resource_templates#copy_existing_template'

  post 'add_role', to: 'resource_templates#add_role'

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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
