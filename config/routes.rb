Rails.application.routes.draw do

  get 'authn/whoami', defaults: {format: :json}
  get 'authn/checkme'

  mount_devise_token_auth_for 'User', at: 'auth'

  scope :api, defaults: {format: :json}  do
    resources :foos, except: [:new, :edit]
    resources :bars, except: [:new, :edit]
    resources :images, except: [:new, :edit] do
      post "thing_images",  controller: :thing_images, action: :create
      get "thing_images",  controller: :thing_images, action: :image_things
      get "linkable_things",  controller: :thing_images, action: :linkable_things
    end
    resources :things, except: [:new, :edit] do
      resources :thing_images, only: [:index, :create, :update, :destroy]
    end

    namespace :things, path: 'things(/:thing_id)' do
      resources :roles, only: [:index, :create, :destroy], path: 'roles/:role_name', param: :user_id do
        # collection do
        #   get :members, :organizers
        # end
      end
    end

    resources :users, only: [:index]
    resources :roles, only: [:index, :show, :create, :update, :destroy]
  end

  get "/client-assets/:name.:format", :to => redirect("/client/client-assets/%{name}.%{format}")
#  get "/", :to => redirect("/client/index.html")

  get '/ui'  => 'ui#index'
  get '/ui#' => 'ui#index'
  root "ui#index"
end
