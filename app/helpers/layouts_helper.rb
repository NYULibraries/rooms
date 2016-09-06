module LayoutsHelper
  def header
    nil
  end

  def gauges_tracking_code
    ENV['ROOMS_GAUGES_TRACKING_CODE']
  end

  def application_stylesheet
    institutional_stylesheet
  end

  # Print breadcrumb navigation
  def breadcrumbs
    breadcrumbs = []
    breadcrumbs << link_to(institution_views["breadcrumbs"]["title"], institution_views["breadcrumbs"]["url"])
    breadcrumbs << link_to('Services', "https://library.nyu.edu/services/")
    breadcrumbs << link_to_unless_current(application_title, root_url)
    breadcrumbs << link_to('Admin', admin_url) if in_admin_view?
    breadcrumbs << link_to_unless_current(controller.controller_name.humanize, {:action => :index }) if in_admin_view?
    return breadcrumbs
  end

  # Prepend modal dialog elements to the body
  def prepend_body
    render 'common/prepend_body'
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

end
