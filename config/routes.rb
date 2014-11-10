Rooms::Application.routes.draw do

  scope "admin" do
    get 'rooms/sort' => "rooms#index_sort", :as => "sort_rooms"
    put 'rooms/sort' => "rooms#update_sort"
    match 'blocks/destroy/:id' => "blocks#destroy", :as => "destroy_block"
    match 'blocks/destroy_existing_reservations' => "blocks#destroy_existing_reservations", :as => 'destroy_existing_reservations'
    match 'blocks/index_existing_reservations' => "blocks#index_existing_reservations", :as => 'index_existing_reservations'

    resources :users
    resources :rooms
    resources :blocks
    resources :reports
    resources :room_groups

    match 'reports' => "reservations#generate_report"
  end
  get 'rooms/:id' => "rooms#show", :as => "show_room_details"

  match 'reservations/resend_email' => "reservations#resend_email"
  resources :reservations do
    put "delete" => "reservations#delete"
  end


  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  devise_scope :user do
    get 'logout', to: 'devise/sessions#destroy', as: :logout
    get 'login', to: redirect('/users/auth/nyulibraries'), as: :login
  end


  match 'admin' => "rooms#index"

  root :to => "reservations#index"
end
