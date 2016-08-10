Rails.application.routes.draw do
  root to: 'landing#index'
  get :about, to: 'static_pages#about'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :edit, :create, :update]
  resources :topics, except: [:show] do
    resources :posts, except: [:show] do
      resources :comments, except: [:show]
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
