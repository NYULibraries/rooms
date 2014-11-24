##
# Todo:
#   * Create a model for this so we can add some validations
class ReportsController < ApplicationController
  # Authorize as symbol without class since this is only for RESTful actions
  authorize_resource :report, :class => false

  #Generate a report of reservations based on submitted params
  def index
    #Make sure the form has been submitted
    unless params[:report].blank?
    
      #Reset the error to nil because it persists from a previous erroneous submission
      flash[:error] = nil
    
      #Find submitted params and set as instance vars
      @room = Room.find(params[:report][:room_id]) unless params[:report][:room_id].eql? "all" or params[:report][:room_id].blank?
      @type_of_room = params[:report][:type_of_room] unless params[:report][:type_of_room].eql? "all" or params[:report][:type_of_room].blank?
      @college_name = params[:report][:college_name] unless params[:report][:college_name].eql? "all" or params[:report][:college_name].blank?
      @college_code = params[:report][:college_code] unless params[:report][:college_code].eql? "all" or params[:report][:college_code].blank?      
      @affiliation = params[:report][:affiliation] unless params[:report][:affiliation].eql? "all" or params[:report][:affiliation].blank?
      @major = params[:report][:major] unless params[:report][:major].eql? "all" or params[:report][:major].blank?
      @patron_status = params[:report][:patron_status] unless params[:report][:patron_status].eql? "all" or params[:report][:patron_status].blank?
    
      #TODO: Move these validations into a model
    
      # Check that the timeslots are in the expected format
      if params[:report][:start_dt].match(/\d\d\d\d-\d\d-\d\d \d\d:(00|30)/) and 
          params[:report][:end_dt].match(/\d\d\d\d-\d\d-\d\d \d\d:(00|30)/) and 
            DateTime.parse(params[:report][:start_dt]) and 
              DateTime.parse(params[:report][:end_dt])
      
        # Convert to datetime objects
        @start_dt = DateTime.parse(params[:report][:start_dt]).to_datetime
        @end_dt = DateTime.parse(params[:report][:end_dt]).to_datetime
    
        # Check that the end date falls after the start date   
        unless @start_dt > @end_dt
          # Generate an array of conditions to be joined with logical ANDs
          conditions = []
          # Add specific room
          conditions.push("(room_id = '#{@room.id}')") unless @room.nil?
          # Add specific type of room
          conditions.push("(room_id in (select id from rooms where type_of_room = '#{@type_of_room}'))") unless @type_of_room.nil?
          # Add specific college name
          conditions.push("(user_id in (select id from users where user_attributes like '%college_name: #{@college_name}%'))") unless @college_name.nil?
          # Add specific college code
          conditions.push("(user_id in (select id from users where user_attributes like '%college_code: #{@college_code}%'))") unless @college_code.nil?
          # Add specific affiliation
          conditions.push("(user_id in (select id from users where user_attributes like '%dept_name: #{@affiliation}%'))") unless @affiliation.nil?  
          # Add specific major
          conditions.push("(user_id in (select id from users where user_attributes like '%major: #{@major}%'))") unless @major.nil?
          # Add specific user status
          conditions.push("(user_id in (select id from users where user_attributes like '%status: \"#{@patron_status}\"%'))") unless @patron_status.nil?

          # Find all reservations that fall between this selected date range      
          @reservations = Reservation.active.no_blocks.accessible_by(current_ability).where("#{conditions.join(' AND ')}#{" AND " unless conditions.empty?}((start_dt BETWEEN ? AND ?) OR (end_dt BETWEEN ? AND ?) OR (start_dt <= ? AND end_dt >= ?))", @start_dt, @end_dt, @start_dt, @end_dt, @start_dt, @end_dt).page(params[:page]).per(30)
        
          # Populate a 'no data found' error if no reservations were found
          flash[:error] = "Could not find any data for the range you selected." if @reservations.empty?
        else
          flash[:error] = "Please select a valid end date that is after your selected start date."
        end
      else
        # Print an error message if dates are invalid
        flash[:error] = "Please select a valid date and time in the format YYYY-MM-DD HH:MM for start and end fields. Note that minutes must be either 00 or 30."
      end
  
      # If there were no errors from the above checks, render report grid
      if flash[:error].blank?
        respond_to do |format|
          format.html { render :report }
          format.csv { render :csv => @reservations, :filename => "reservations_report.#{Time.now.strftime("%Y%m%d%H%m")}" }
        end
      else 
        # If there were error messages, render with errors
        render :index
      end  
    end
  end
  
end