class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # guest user
    # For each role this user has, call the corresponding function
    @user.auth_roles.each { |role| send(role) if respond_to?(role) } unless @user.is_admin?
    # For admins ignore the standard permissions
    @user.admin_roles.each { |role| send(role) if respond_to?(role) } if @user.is_admin? and !@user.is? :superuser
    # Force only superuser permissions for superuser admin
    send("superuser") if @user.is? :superuser
  end

  def ny_undergraduate
    group_access = [__method__]
    shared_booker(group_access, __method__)
  end

  def shanghai_undergraduate
    group_access = [__method__]
    shared_booker(group_access, __method__)
  end

  def abu_dhabi_undergraduate
    group_access = [__method__]
    shared_booker(group_access, __method__)
  end

  def ny_graduate
    group_access = [__method__, :ny_undergraduate]
    shared_booker(group_access, __method__)
    # Can't make reservations for greater than 3 hours
    can :create_for_length, Reservation do |reservation|
      ((reservation.end_dt.to_time - reservation.start_dt.to_time) / 60 / 60) <= 3.0 #3.hours
    end
  end

  def superuser
    can :manage, :all
    cannot :destroy, User, :id => @user.id
  end

  def ny_admin
    group_access = [:ny_graduate, :ny_undergraduate]
    shared_admin(group_access, __method__)
  end

  def shanghai_admin
    group_access = [:shanghai_undergraduate]
    shared_admin(group_access, __method__)
  end

  def abu_dhabi_admin
    group_access = [:abu_dhabi_undergraduate]
    shared_admin(group_access, __method__)
  end

private

  ##
  # Actions that all admins can do based on their group access and role name
  def shared_admin(group_access, method_name)
    # Manage reservations if they are in rooms you manage
    can :manage, Reservation, {:room => {:room_group => { :code => group_access.map {|g| g.to_s } }}}
    can [:create_today, :create_for_same_day, :create_for_length], Reservation
    can :manage, :block
    can [:read, :update, :create], User
    # Destroy user if it isn't you, it isn't an admin or it is an admin you can edit
    can :destroy, User do |user|
      user.id != @user.id and (!user.is_admin? or user.is? method_name)
    end
    # Room access
    can group_access, RoomGroup
    can :new, Room
    can :manage, Room, {:room_group => { :code => group_access.map {|g| g.to_s } } }
  end

  ##
  # Actions that all bookers can do based on their group access and role name
  def shared_booker(group_access, method_name)
    can group_access, RoomGroup

    can [:read, :create, :delete, :update, :resend_email], Reservation, { :user_id => @user.id, :room => {:room_group => { :code => group_access.map {|g| g.to_s } } } }
    # Grads can't make a reservations if they've made one today
    can :create_today, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.made_today? }
    end
    # Grads can't make a reservation if they've aready made one for that day
    can :create_for_same_day, Reservation do |reservation|
      @user.reservations.none? {|r| !r.new_record? && r.on_same_day?(reservation) }
    end
    # Can't make reservations for greater than 2 hours
    can :create_for_length, Reservation do |reservation|
      ((reservation.end_dt.to_time - reservation.start_dt.to_time) / 60 / 60) <= 2.0 #2.hours
    end
    can :show, Room
  end

end
