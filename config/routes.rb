TraitDB::Application.routes.draw do

  # Devise, an auth framework
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # Resourceful routes
  resources :projects do
    member do
      get 'delete'
    end
  end

  resources :continuous_trait_values
  resources :categorical_trait_values
  resources :categorical_trait_categories
  resources :categorical_traits
  resources :continuous_traits
  resources :otus
  resources :taxa
  resources :source_references
  resources :csv_import_configs

  # wizard import interface after uploading
  resources :import_jobs do
    resources :after_upload, :controller => 'after_upload' do
      member do
        get 'download_problematic_rows'
        get 'download_issues'
      end
    end
  end

  # read-only interface for browsing import jobs
  resources :csv_datasets do
    resources :import_jobs
  end

  # Non-resourceful routes
  match 'select_project' => 'projects#select_project'
  match 'selected_project' => 'projects#selected_project'

  match 'search(/:action)(.:format)' => "search"
  match 'about' => 'about#index'
  match 'upload(/:action)(/:id)(.:format)' => 'upload'
  match 'csv_templates(/:action)(/:id)(.:format)' => 'csv_template'
  root :to => "about#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
