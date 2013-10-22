class Ability
  include CanCan::Ability

  def initialize(user)    
    user ||= User.new # guest user (not logged in)  
    
    alias_action :create, :read, :update, :destroy, :to => :crud
    
    booker(user) if user.is_authorized?
    shanghai_undergraduate(user) if user.is_shanghai_undergraduate?
    ny_graduate(user) if user.is_ny_graduate?
    admin(user) if user.is_admin?
    ny_undergraduate(user) if user.is_ny_undergraduate?
  end
  
  def booker(user)
    can :crud, Reservation, :user_id => user.id
    #cannot :create, Reservation if user.reservations.rr_made_today? or user.reservations.rr_for_same_day?
  end

  def shanghai_undergraduate(user)
    ny_undergraduate(user)
  end
  
  def ny_undergraduate(user)
    booker(user)
    cannot :create, Reservation, :graduate => true
    cannot :manage, Room
  end  

  def ny_graduate(user)
    booker(user)
    can :create, Reservation, :graduate => true
  end

  def admin(user)
    can :manage, :all 
    cannot [:destroy, :update], User, :id => user.id
  end


end