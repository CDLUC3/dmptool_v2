Dmptool2::Application.routes.draw do

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resources :resources
      resources :institutions
      resources :users
      resources :requirements_templates
      resources :roles
      resources :requirements
      resources :comments
      resources :plans
      resources :resource_contexts
      resources :responses
      resources :published_plans
      resources :plans_states
      resources :sample_plans

      get 'institutions_plans_count/:id', to: 'institutions#plans_count_show'
      get 'institutions_plans_count', to: 'institutions#plans_count_index'
      get 'institutions_admins_count/:id', to: 'institutions#admins_count_show'
      get 'institutions_admins_count', to: 'institutions#admins_count_index'

    end
  end


  match '/500', :to => 'errors#internal_error', :via => :all
  match '/404', :to => 'errors#not_found', :via => :all
  match '/403', :to => 'errors#forbidden', :via => :all

  get "dashboard/show"
  root 'static_pages#home'
  get 'about', to: 'static_pages#about'
  get 'community_resources', to: 'static_pages#community_resources'
  match 'contact', to: 'static_pages#contact', :via => [:get, :post], as: 'contact'
  get 'dashboard', to: 'dashboard#show', as: 'dashboard'
  get 'dashboard/test', to: 'dashboard#test'
  get 'dm_guidance', to: 'static_pages#data_management_guidance'
  get 'guidance', to: 'static_pages#guidance'
  get 'help', to: 'static_pages#help'
  get 'logout', to: 'user_sessions#destroy'
  get 'partners', to: 'static_pages#partners'
  get 'partners_list', to: 'institutions#partners_list'
  get 'privacy', to: 'static_pages#privacy'
  get 'promote', to: 'static_pages#promote'
  get 'terms_of_use', to: 'static_pages#terms_of_use'
  get 'video', to: 'static_pages#video'
  get 'resource_contexts/dmp_for_customization', to: 'resource_contexts#dmp_for_customization', as: "dmp_for_customization"
  get 'resource_contexts/choose_institution', to: 'resource_contexts#choose_institution'
  post 'requirements/reorder', to: 'requirements#reorder', as: "reorder_requirements"
  get 'customizations/:id/requirements/(:requirement_id)', to: 'customizations#show', as: 'customization_requirement'
  get 'institutions', to: 'institutions#index'

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

  resources :resources
  resources :resource_contexts

  #this routes needs to stay above the other user ones to take priority
  get 'users/autocomplate_users', to: 'users#autocomplete_users', as: 'users_autocomplete'
  get 'users/autocomplate_users_plans', to: 'users#autocomplate_users_plans', as: 'autocomplate_users_plans'
  resources :users do
    resources :plan_states
    member do
      get :edit_roles
      get :finish_signup
      patch :finish_signup_update
    end
  end

  # resources :resources do
  #   resources :resource_contexts
  # end

  resources :plans do
    post "plan_states/approved"
    post "plan_states/rejected"
    post "plan_states/submitted"
    post "plan_states/committed"
    post "plan_states/reviewed"
    member do
      post :add_coowner
      get :publish
      get :export
      get :details
      get :preview
      get :perform_review
    end
  end
  resources :comments
  resources :responses

  resources :institutions
  resources :authorizations

  match 'user_sessions/login', to: 'user_sessions#login', as: 'login', :via => [:get, :post]
  get 'user_sessions/institution', to: 'user_sessions#institution', as: 'choose_institution'
  match '/auth/:provider/callback', to: 'user_sessions#create', :via => [:get, :post]
  get '/auth/failure', to: 'user_sessions#failure'
  match 'user_sessions/username_reminder', to: 'user_sessions#username_reminder', :via => [:get, :post]
  match 'user_sessions/password_reset', to: 'user_sessions#password_reset', :via => [:get, :post]
  match 'user_sessions/complete_password_reset', to: 'user_sessions#complete_password_reset', as: 'complete_password_reset', :via => [:get, :post]
  get 'requirements_template_information', to: 'requirements_templates#template_information'
  get 'copy_existing_requirements_template', to: 'requirements_templates#copy_existing_template'

  get 'plan_template_information', to: 'plans#template_information'
  get 'copy_existing_plans_template', to: 'plans#copy_existing_template'
  get 'select_dmp_template', to: 'plans#select_dmp_template'
  get 'review_dmps', to: 'plans#review_dmps'
  post 'change_visibility', to: 'plans#change_visibility'
  get 'public_dmps', to: 'plans#public'
  post 'add_coowner_autocomplete', to: 'plans#add_coowner_autocomplete'
  delete 'delete_coowner', to: 'plans#delete_coowner'
  post 'reject_with_comments', to: 'plan_states#reject_with_comments'

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

  post  'add_authorization_manage_users', to: 'authorizations#add_authorization_manage_users'

  get 'edit_customization_resource', to: 'resources#edit_customization_resource'
  patch 'update_customization_resource', to: 'resources#update_customization_resource'

  post 'new_customization_resource', to: 'resources#new_customization_resource'
  post 'create_customization_resource', to: 'resources#create_customization_resource'

  delete 'delete_resource', to: 'resources#destroy'

  post 'select_resource', to: 'resource_contexts#select_resource'
  get 'select_resource', to: 'resource_contexts#select_resource'

  delete 'delete_resource_context', to: 'resource_contexts#destroy'

  post 'create_customization_resource_from_select_resource', to: 'resources#create_customization_resource_from_select_resource'

  post 'copy_selected_customization_resource', to: 'resources#copy_selected_customization_resource'

  post 'unlink_resource_from_template', to: 'resource_contexts#unlink_resource_from_template'
  post 'unlink_resource_from_requirement', to: 'resource_contexts#unlink_resource_from_requirement'
  post 'unlink_resource_from_customization', to: 'resource_contexts#unlink_resource_from_customization'


  post 'unlink_institutional_resource', to: 'resource_contexts#unlink_institutional_resource'



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
