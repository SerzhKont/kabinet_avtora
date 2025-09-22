Rails.application.routes.draw do
  resource :session, only: [ :new, :create, :destroy ]
  resources :documents, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    collection do
      delete :bulk_delete
    end
  end
  resources :authors
  root "documents#index"
  resources :passwords, param: :token
  post "dismiss_notification", to: "application#dismiss_notification", as: :dismiss_notification
  get "author_documents/:author_code", to: "documents#author_index", as: :author_documents  # Magic link endpoint
  post "author_documents/:author_code/sign_one/:id", to: "documents#sign_one", as: :sign_one_document
  post "author_documents/:author_code/sign_all", to: "documents#sign_all", as: :sign_all_author_documents
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
