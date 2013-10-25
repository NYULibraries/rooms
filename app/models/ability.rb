class Ability
  include CanCan::Ability

  def initialize(user)    
    @user = user || User.new # guest user
    # For each role this user has, call the corresponding function
    @user.auth_roles.each { |role| send(role) if respond_to?(role) } unless @user.is_admin?
    # For admins ignore the standard permissions
    @user.admin_roles.each { |role| send(role) if respond_to?(role) } if @user.is_admin? and !@user.is? :global
    # Force only global permissions for global admin
    send("global") if @user.is? :global
  end
  
  def booker
    
    #cannot :create, Reservation do |reservation|
    #  reservation.room.room_group.code == "ny_graduate"
    #end
    #cannot :create, Reservation do |reservation|
    #  !user.reservations.any? {|r| r.on_same_day?(reservation) }
    #end
  end
  
  def ny_undergraduate
    can :manage, Reservation, {:user_id => @user.id, :room => {:room_group => { :code => }}
    can :create, Reservation do |reservation|
      #, {:room_group => { :code => ["ny_graduate", "ny_undergraduate"] }}
      
    end
  end  

  def shanghai_undergraduate
    ny_undergraduate
  end

  def ny_graduate
    can :create, Reservation, :graduate => true
  end

  def global
    can :manage, :all
    cannot :destroy, User, :id => @user.id
  end
    
  def ny_admin
    can :manage, Reservation
    can :manage, User
    can :manage, :block
    can :manage, :report
    cannot :destroy, User, :id => @user.id
    can [:ny_graduate, :ny_undergraduate], RoomGroup
    can :manage, Room, {:room_group => { :code => ["ny_graduate", "ny_undergraduate"] }}
  end
  
  def shanghai_admin
    can :manage, Reservation
    can :manage, User
    can :manage, :block
    can :manage, :report
    cannot :destroy, User, :id => @user.id
    can [:shanghai_undergraduate], RoomGroup
    can :manage, Room, {:room_group => { :code => ["shanghai_undergraduate"] }}
  end

end