class Ability
  include CanCan::Ability

  def initialize(user)    
    user ||= User.new # guest user (not logged in)  
    
    alias_action :create, :read, :update, :destroy, :to => :crud
    
    undergraduate(user) if user.is_undergraduate?
    graduate(user) if user.is_graduate?
    admin(user) if user.is_admin? && !user.is?(:superuser)
    superuser(user) if user.is? :superuser
  end
  
  def undergraduate(user)
    can :crud, Reservation, :user_id => user.id
    cannot :crud, Reservation, :graduate => true
  end

  def graduate(user)
    undergraduate(user)
    can :create, Reservation, :graduate => true
    #cannot :create, Reservation if user.reservations.rr_made_today? or user.reservations.rr_for_same_day?
  end

  def admin(user)
    can :manage, :all 
    cannot :destroy, User, :id => user.id
    cannot :manage, Room
    cannot :update, User, :id => user.id
  end

  def superuser(user)
    can :manage, :all
    cannot :destroy, User, :id => user.id
  end

end