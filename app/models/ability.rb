class Ability
    include CanCan::Ability

    def initialize(user)
      can :manage, :all if user.is? :admin
      
      if user.role? :booker
        #rules for registred user
        can :create, Reservation
        can :destroy, Reservation do |reservation|
          reservation.try(:user) == user
        end
        can :update, Reservation do |reservation|
          reservation.try(:user) == user
        end
      end
   end
end