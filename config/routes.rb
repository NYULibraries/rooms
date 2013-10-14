Rooms::Application.routes.draw do
  scope "admin" do
    get 'rooms/sort' => "rooms#index_sort", :as => "sort_rooms"
    put 'rooms/sort' => "rooms#update_sort"
    
    resources :user_sessions
    resources :users
    resources :rooms
    resources :blocks 
    resources :reports
    
    match 'reservations/destroy/:id' => "reservations#destroy", :as => "admin_reservation_destroy"
    match 'blocks/generate' => "blocks#generate", :as => 'generate', :via => :post
    match 'blocks/destroy/:id' => "blocks#destroy", :as => "destroy_block"
   
    match 'reports' => "reservations#generate_report"
  end
  
  match 'reservations/generate_grid' => "reservations#generate_grid", :as => 'generate_grid'
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
