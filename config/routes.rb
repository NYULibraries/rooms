Rooms::Application.routes.draw do
  mount Peek::Railtie => '/peek'
  
  scope "admin" do
    get 'rooms/sort' => "rooms#index_sort", :as => "sort_rooms"
    put 'rooms/sort' => "rooms#update_sort"
    match 'blocks/destroy/:id' => "blocks#destroy", :as => "destroy_block"
    match 'blocks/destroy_existing_reservations' => "blocks#destroy_existing_reservations", :as => 'destroy_existing_reservations'
    match 'blocks/index_existing_reservations' => "blocks#index_existing_reservations", :as => 'index_existing_reservations'
    
    resources :user_sessions
    resources :users
    resources :rooms
    resources :blocks 
    resources :reports
    resources :room_groups
   
    match 'reports' => "reservations#generate_report"
  end
  
  match 'reservations/resend_email' => "reservations#resend_email"
  resources :reservations do
    put "delete" => "reservations#delete"
  end
  
  match 'login', :to => 'user_sessions#new', :as => :login
  match 'logout', :to => 'user_sessions#destroy', :as => :logout
  match 'validate', :to => 'user_sessions#validate', :as => :validate
  
  match 'admin' => "rooms#index"

  root :to => "reservations#index"
end
