class Ability
  include CanCan::Ability

  def initialize(user)    
    @user = user || User.new # guest user
    # For each role this user has, call the corresponding function
    @user.auth_roles.each { |role| send(role) if respond_to?(role) } #unless @user.is_admin?
    # For admins ignore the standard permissions
   # @user.admin_roles.each { |role| send(role) if respond_to?(role) } if @user.is_admin? and !@user.is? :global
    # Force only global permissions for global admin
    #send("global") if @user.is? :global
  end
  
  def ny_undergraduate
    can [__method__], RoomGroup
    can [:read, :create, :new, :delete, :update, :edit, :resend_email], Reservation, { :user_id => @user.id, :room => {:room_group => { :code => __method__.to_s } } }
    cannot :create, Reservation if @user.reservations.any? {|r| r.made_today? }
    #can :create, Reservation do |reservation|
    #  !@user.reservations.any? {|r| r.on_same_day?(reservation) }
    #end
  end  

  def shanghai_undergraduate
    can [__method__], RoomGroup
    can :manage, Reservation, { :user_id => @user.id, :room => {:room_group => { :code => __method__.to_s } } }
  end

  def ny_graduate
    can [__method__, :ny_undergraduate], RoomGroup
    can :create, Reservation, { :user_id => @user.id, :room => {:room_group => { :code => __method__.to_s } } }
  end

  def global
    can :manage, :all
    cannot :destroy, User, :id => @user.id
  end
    
  def ny_admin
    group_access = [:ny_graduate, :ny_undergraduate]
    can :manage, Reservation, {:room => {:room_group => { :code => group_access.map {|g| g.to_s } }}}
    can :manage, :block
    can :manage, User
    can :manage, :report
    cannot :destroy, User, :id => @user.id
    can group_access, RoomGroup
    can :manage, Room, {:room_group => { :code => group_access.map {|g| g.to_s } } }
    can :create, Room
  end
  
  def shanghai_admin
    group_access = [:shanghai_undergraduate]
    can :manage, Reservation, {:room => {:room_group => { :code => group_access.map {|g| g.to_s } }}}
    can :manage, :block
    can :manage, User
    can :manage, :report
    cannot :destroy, User, :id => @user.id
    can group_access, RoomGroup
    can :manage, Room, {:room_group => { :code => group_access.map {|g| g.to_s } }}
    can :create, Room
  end

end