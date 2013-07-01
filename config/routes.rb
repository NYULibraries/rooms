Rooms::Application.routes.draw do
  scope "admin" do
    resources :user_sessions
    resources :users
    resources :rooms
    resources :blocks 
    resources :reports
    
    match 'reservations/destroy/:id' => "reservations#destroy", :as => "admin_reservation_destroy"
    match 'blocks/generate' => "blocks#generate", :as => 'generate', :via => :post
    match 'blocks/destroy/:id' => "blocks#destroy", :as => "destroy_block"
    
    match 'rooms/update_order' => "rooms#update_order", :as => "update_order"
    match 'rooms/refresh_images_list' => "rooms#refresh_images_list"
   
    match 'reports' => "reservations#generate_report"
  end
  
  match 'reservations/generate_grid' => "reservations#generate_grid", :as => 'generate_grid'
  match 'reservations/resend_email' => "reservations#resend_email"
  resources :reservations
  
  match 'login', :to => 'user_sessions#new', :as => :login
  match 'logout', :to => 'user_sessions#destroy', :as => :logout
  match 'validate', :to => 'user_sessions#validate', :as => :validate
  
  match 'admin' => "rooms#index"

  root :to => "reservations#index"
end
