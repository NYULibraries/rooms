module Roles
  module Authorization
    def self.included(base); end

    ##
    # Gets Hash of all authorized roles
    def all_auth_roles
      @auth_roles ||= YAML.load(ENV['ROOMS_ROLES_AUTHORIZED'])
    end

    ##
    # Gets Array of all admin roles
    def all_admin_roles
      @admin_roles ||= YAML.load(ENV['ROOMS_ROLES_ADMIN'])
    end

    ##
    # Bitwise roles field in database per https://github.com/ryanb/cancan/wiki/Role-Based-Authorization#many-roles-per-user
    #
    # = Example
    #
    #   user.roles = ["global", "ny_admin"]
    def admin_roles=(roles)
      self.admin_roles_mask = (roles & all_admin_roles).map { |r| 2**all_admin_roles.index(r) }.inject(0, :+)
    end

    ##
    # This user's admin_roles based off the bitwise mask
    def admin_roles
      all_admin_roles.reject {|r| ((admin_roles_mask.to_i || 0) & 2**all_admin_roles.index(r)).zero? }
    end

    ##
    # This user's authorized roles based off their bor status
    def auth_roles
      all_auth_roles.reject {|k,v| !v.include? self.patron_status }.keys.map {|k| k.to_s}
    end

    ##
    # Array of all roles, admin and authorized, this user has
    def roles
      @roles ||= Array[auth_roles, admin_roles].flatten
    end

    ##
    # Full comma-delimited list of roles, authorized and admin
    def roles_list
      @roles_list ||= Array[admin_roles_list, auth_roles_list].flatten.reject {|r| r.empty?}.join(", ")
    end

    ##
    # List of comma-delimited admin roles
    def admin_roles_list
      @admin_roles_list ||= listify(admin_roles)
    end

    ##
    # List of comma-delimited authorized roles
    def auth_roles_list
      @auth_roles_list ||= listify(auth_roles)
    end

    ##
    # Answer the question does this user have this role
    #
    # = Example
    #
    #   @user.is? :global
    def is?(role)
      roles.include?(role.to_s)
    end

    def is_authorized?
      @is_authorized ||= Rails.cache.fetch "#{self.patron_status}_authorized", :expires_in => 24.hours do
        all_auth_roles.delete_if {|key,value| !value.include? self.patron_status }.blank?
      end
    end

    def is_admin?
      all_admin_roles.any? {|role| self.is? role}
    end


    ##
    # Allows calling of functions like is_arbitrary_role?
    def method_missing(method_id, *args)
      if match = matches_dynamic_role_check?(method_id)
        self.is? match.captures.first
      else
        super
      end
    end

private

    def listify(arr)
      arr.join(", ").humanize.titleize
    end

    ##
    # Check if method_id matches the is_role? schema
    def matches_dynamic_role_check?(method_id)
      /^is_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

  end
end
