module Rooms
  module User
    module Authorization
      ROLES = Settings.roles.admin #%w[global ny_admin shanghai_admin]    
    
      def self.included(base)
      end
  
      ##
      # Bitwise roles field in database per https://github.com/ryanb/cancan/wiki/Role-Based-Authorization#many-roles-per-user
      #
      # = Example
      # 
      #   user.roles = ["global", "ny_admin"]
      def roles=(roles)
        self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
      end

      ##
      # This user's admin_roles based off the bitwise mask
      def roles
        ROLES.reject do |r|
          ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
        end
      end

      def roles_list
        roles.join(", ").humanize.titleize
      end

      def is?(role)
        roles.include?(role.to_s) || ((auth_roles[role.to_sym].blank? || attrs[:bor_status].blank?) ? false : auth_roles[role.to_sym].include?(attrs[:bor_status].to_s))
      end

      def auth_roles
        @auth_roles ||= Hash[Settings.roles.authorized]
      end

      def is_authorized?
        return false if (attrs.blank? || attrs[:bor_status].blank?)
        @is_authorized ||= Rails.cache.fetch "#{attrs[:bor_status]}_authorized", :expires_in => 24.hours do
          auth_roles.delete_if {|key,value| !value.include? attrs[:bor_status] }.blank?
        end
      end

      #validate :set_admins, Settings.login.default_admins.include? pds_user.uid #user.roles = ["global"]
      def is_admin?
        ROLES.any? {|role| self.is? role}
      end

      def attrs
        (defined?(current_user)) ? current_user.user_attributes : user_attributes
      end
    
      def method_missing(method_id, *args)
        if match = matches_dynamic_role_check?(method_id)
          self.is? match.captures.first
        else
          super
        end
      end

private

      def matches_dynamic_role_check?(method_id)
        /^is_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
      end
    
    end
  end
end