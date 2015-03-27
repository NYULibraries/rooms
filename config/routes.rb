Rooms::Application.routes.draw do

  scope "admin" do
    get 'rooms/sort' => "rooms#index_sort", :as => "sort_rooms"
    put 'rooms/sort' => "rooms#update_sort"
    match 'blocks/destroy/:id' => "blocks#destroy", :as => "destroy_block", via: [:get, :post]
    match 'blocks/destroy_existing_reservations' => "blocks#destroy_existing_reservations", :as => 'destroy_existing_reservations', via: [:get, :post]
    match 'blocks/index_existing_reservations' => "blocks#index_existing_reservations", :as => 'index_existing_reservations', via: [:get, :post]

    resources :user_sessions
    resources :users
    resources :rooms
    resources :blocks
    resources :reports
    resources :room_groups

    match 'reports' => "reservations#generate_report", via: [:get, :post]
  end
  get 'rooms/:id' => "rooms#show", :as => "show_room_details"

  match 'reservations/resend_email' => "reservations#resend_email", via: [:get, :post]
  resources :reservations do
    put "delete" => "reservations#delete"
  end

  match 'login', :to => 'user_sessions#new', :as => :login, via: [:get, :post]
  match 'logout', :to => 'user_sessions#destroy', :as => :logout, via: [:get, :post]
  match 'validate', :to => 'user_sessions#validate', :as => :validate, via: [:get, :post]

  match 'admin' => "rooms#index", via: [:get, :post]

  root :to => "reservations#index"
end
