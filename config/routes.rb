Rails.application.routes.draw do
  get "document_groups/show"
  root "documents#index"

  resource :session, only: [ :new, :create, :destroy ]
  resources :documents, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    collection do
      post :bulk_action
      get :confirm_bulk_destroy
      get :confirm_bulk_send_for_signature
    end
    member do
      get :confirm_destroy
      get :confirm_send_for_signature
      post :send_single
    end
  end
  resources :authors
  resources :passwords, param: :token
  post "dismiss_notification", to: "application#dismiss_notification", as: :dismiss_notification
  get "/view_documents/:token", to: "document_groups#show", as: :document_group
  get "/view_documents/:token/documents/:id", to: "document_groups#show_document", as: :view_document_group_document
  get "/view_documents/:token/sign", to: "document_groups#sign", as: :sign_document_group
  post "/view_documents/:token/signing", to: "document_groups#signing", as: :signing_document_group
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
