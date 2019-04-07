Rails.application.routes.draw do
  root 'home#top'

  #ユーザー関連
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  resources :users, only: [:show]
  
  #サブスクリプション
  resources :subscriptions do
    resources :additions, only: [:create, :destroy]
    post :import, on: :collection
  end
  resources :details

  #問い合わせ
  resources :contacts, only: [:new, :create]
end
