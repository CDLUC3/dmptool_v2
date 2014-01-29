Dmptool2::Application.routes.draw do

 get "dashboard/show"
 root 'static_pages#home'
 get 'about', to: 'static_pages#about'
 get 'community_resources', to: 'static_pages#community_resources'
 match 'contact', to: 'static_pages#contact', :via => [:get, :post], as: 'contact'
 get 'dashboard', to: 'dashboard#show', as: 'dashboard'
 get 'dashboard/test', to: 'dashboard#test'
 get 'data_management_guidance', to: 'static_pages#data_management_guidance'
 get 'guidance', to: 'static_pages#guidance'
 get 'help', to: 'static_pages#help'
 get 'logout', to: 'user_sessions#destroy'
 get 'partners', to: 'static_pages#partners'
 get 'partners_list', to: 'static_pages#partners_list'
 get 'privacy', to: 'static_pages#privacy'
 get 'promote', to: 'static_pages#promote'
 get 'terms_of_use', to: 'static_pages#terms_of_use'
 get 'video', to: 'static_pages#video'
 get 'requirements_templates/test', to: 'requirements_templates#test'

  resources :requirements_templates do
    resources :requirements
    resources :resource_contexts
    member do
      get :toggle_active
      get :basic
    end
    resources :sample_plans
    resources :additonal_informations
  end

  resources :resource_templates do
    resources :resource_contexts
  end

  resources :users do
    member do
      get :edit_roles
      get :finish_signup
      patch :finish_signup_update
    end
  end

  resources :resources do
    resources :resource_contexts
  end

  resources :roles
  resources :plans
  resources :institutions
  resources :authorizations

  match 'user_sessions/login', to: 'user_sessions#login', as: 'login', :via => [:get, :post]
  get 'user_sessions/institution', to: 'user_sessions#institution', as: 'choose_institution'
  match '/auth/:provider/callback', to: 'user_sessions#create', :via => [:get, :post]
  get '/auth/failure', to: 'user_sessions#failure'
  match 'user_sessions/username_reminder', to: 'user_sessions#username_reminder', :via => [:get, :post]
  match 'user_sessions/password_reset', to: 'user_sessions#password_reset', :via => [:get, :post]
  match 'user_sessions/complete_password_reset', to: 'user_sessions#complete_password_reset', as: 'complete_password_reset', :via => [:get, :post]

  get 'users/autocomplate_template_editors', to: 'users#autocomplete_template_editors', as: 'template_editor_users_autocomplete'
  get 'users/autocomplate_resource_editors', to: 'users#autocomplete_resource_editors', as: 'resource_editor_users_autocomplete'

  get 'requirements_template_information', to: 'requirements_templates#template_information'
  get 'copy_existing_requirements_template', to: 'requirements_templates#copy_existing_template'

  get  'remove_resource_editor_role', to: 'resource_templates#remove_resource_editor_role'
  get  'remove_requirements_editor_role', to: 'requirements_templates#remove_requirements_editor_role'

  post 'add_role', to: 'resource_templates#add_role'
  post 'add_requirements_editor_role', to: 'requirements_templates#add_requirements_editor_role'

  post 'add_authorization', to: 'authorizations#add_authorization'
  get 'remove_authorization', to: 'authorizations#remove_authorization'
  post 'add_role_autocomplete', to: 'authorizations#add_role_autocomplete'

  get  'edit_user_roles', to: 'users#edit_user_roles'
  post  'update_user_roles', to: 'users#update_user_roles'

  get  'edit_user_roles_inst_admin', to: 'institutions#edit_user_roles_inst_admin'
  post  'update_user_roles_inst_admin', to: 'institutions#update_user_roles_inst_admin'

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
