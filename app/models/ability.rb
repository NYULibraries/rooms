class Ability
    include CanCan::Ability

    def initialize(user)    
      user ||= User.new # guest user (not logged in)  
      #shanghai_admin(user) if user.is? :shanghai_admin
      #ny_admin(user) if user.is? :ny_admin
      #superuser(user) if user.is? :superuser
      undergraduate(user)
   end
   
   def undergraduate(user)
     can :manage, Reservation, :user_id => user.id
     cannot :manage, Reservation, :graduate => true
   end
   
   def graduate(user)
     undergraduate(user)
     can :create, Reservation, :graduate => true
     can :create, Reservation unless user.reservations.rr_made_today? or user.reservations.rr_for_same_day?
   end
   
   def shanghai(user)
     undergraduate(user)
     graduate(user)
   end
   
   def ny_admin(user)
     admin(user)
     cannot :manage, Room, :location => :shanghai
   end
   
   def admin(user)
     can :manage, :all
     cannot :manage, Room
   end
   
   def superuser(user)
     admin(user)
     can :manage, :all
     cannot :destroy, User, :user_id => user.id
   end
   
   def authorized(user)
     # user.is? :shanghai-undergraduate
     # user.is? :ny-undergraduate
     # user.is? :ny-graduate
     # user.is? :admin
   end
  
end