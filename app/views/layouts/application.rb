# app/views/layouts/bobcat.rb
module Views
  module Layouts
    class Application < ActionView::Mustache
      # Meta tags to include in layout
      def meta
        meta = super
        meta << tag(:meta, :name => "HandheldFriendly", :content => "True")
        meta << tag(:meta, :name => "cleartype", :content => "on")
        meta << favicon_link_tag('https://library.nyu.edu/favicon.ico')
      end
      
      # Stylesheets to include in layout
      def stylesheets
        catalog_stylesheets = stylesheet_link_tag "http://fonts.googleapis.com/css?family=Muli"
        catalog_stylesheets += stylesheet_link_tag "application"
      end

      # Javascripts to include in layout
      def javascripts
        catalog_javascripts = javascript_include_tag "application"
      end
      
      def application
       "Reserve a room"
      end
      
      def title
        application
      end
      
      # Using Gauges?
      def gauges?
        (Rails.env.eql?("production") and (not gauges_tracking_code.nil?))
      end

      def gauges_tracking_code
        Settings.gauges.tracking_code
      end
      
      # Print breadcrumb navigation
      def breadcrumbs
        breadcrumbs = super
        breadcrumbs << link_to_unless_current(title, root_url)
        breadcrumbs << link_to('Admin', admin_url) if is_in_admin_view?
        breadcrumbs << link_to_unless_current(controller.controller_name.humanize, {:action => :index }) if is_in_admin_view?
        return breadcrumbs
      end
      
      # Render footer partial
      def footer
        render :partial => "common/footer"
      end
      
      # Prepend modal dialog elements to the body
      def prepend_body
        render :partial => "common/modal"
      end
      
      # Prepend the flash message partial before yield
      def prepend_yield
        content_tag :div, :id => "main-flashses" do
         render :partial => 'common/flash_msg'
        end
      end

      # Boolean for whether or not to show tabs
      # This application doesn't need tabs
      def show_tabs
        false
      end
      
      # Boolean for whether or not to show search box
      # For this application only show tabs when not in admin view
      def show_search_box?
        !is_in_admin_view?
      end
    
    end
  end
end