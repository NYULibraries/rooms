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
  
  def ny_undergraduate
    can [__method__], RoomGroup
    can [:read, :create, :new, :delete, :update, :edit, :resend_email], Reservation, { :user_id => @user.id, :room => {:room_group => { :code => __method__.to_s } } }
    # Undergrads can't make a reservations if they've made one today
    can :made_today, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.made_today? }
    end
    # Undergrads can't make a reservation if they've aready made one for that day
    can :for_same_day, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.on_same_day?(reservation) }
    end
    # Undergrads can make reservations for up to 2 hours
    can :create_length, Reservation do |reservation|
      ((reservation.end_dt.to_time - reservation.start_dt.to_time) / 60 / 60) <= 2.0 #2.hours
    end
  end
  
  def shanghai_undergraduate
    can [__method__], RoomGroup
    can [:read, :create, :new, :delete, :update, :edit, :resend_email], Reservation, { :user_id => @user.id, :room => {:room_group => { :code => __method__.to_s } } }
    # Undergrads can't make a reservations if they've made one today
    can :made_today, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.made_today? }
    end
    # Undergrads can't make a reservation if they've aready made one for that day
    can :for_same_day, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.on_same_day?(reservation) }
    end
    # Undergrads can make reservations for up to 2 hours
    can :create_length, Reservation do |reservation|
      ((reservation.end_dt.to_time - reservation.start_dt.to_time) / 60 / 60) <= 2.0 #2.hours
    end
  end

  def ny_graduate
    group_access = [__method__, :ny_undergraduate]
    can group_access, RoomGroup
    can [:read, :create, :new, :delete, :update, :edit, :resend_email], Reservation, { :user_id => @user.id, :room => {:room_group => { :code => group_access.map {|g| g.to_s } } } }
    # Grads can't make a reservations if they've made one today
    can :made_today, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.made_today? }
    end
    # Grads can't make a reservation if they've aready made one for that day
    can :for_same_day, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.on_same_day?(reservation) }
    end
    # Grads can make reservations for up to 2 hours
    can :create_length, Reservation do |reservation|
      ((reservation.end_dt.to_time - reservation.start_dt.to_time) / 60 / 60) <= 3.0 #3.hours
    end
  end
  
  def global
    can :manage, :all
    cannot :destroy, User, :id => @user.id
  end
    
  def ny_admin
    group_access = [:ny_graduate, :ny_undergraduate]
    can :manage, Reservation, {:room => {:room_group => { :code => group_access.map {|g| g.to_s } }}}
    can :manage, Reservation
    can :manage, :block
    can :manage, User
    can :manage, :report
    cannot :destroy, User, :id => @user.id
    can group_access, RoomGroup
    can :manage, Room, {:room_group => { :code => group_access.map {|g| g.to_s } } }
    can :create, Room
    can :admin, Room
  end
  
  def shanghai_admin
    group_access = [:shanghai_undergraduate]
    can [:made_today, :for_same_day, :create_length], Reservation
    can :manage, Reservation, {:room => {:room_group => { :code => group_access.map {|g| g.to_s } }}}
    can :manage, Reservation
    can :manage, :block
    can :manage, User
    can :manage, :report
    cannot :destroy, User, :id => @user.id
    can group_access, RoomGroup
    can :manage, Room, {:room_group => { :code => group_access.map {|g| g.to_s } }}
    can :create, Room
    can :admin, Room
  end

end