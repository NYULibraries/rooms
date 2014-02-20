# Fit modal body to the screen size
window.fit_modal_body = (modal) ->
  header = $(".modal-header", modal)
  body = $(".modal-body", modal)
  footer = $(".modal-footer", modal)
  windowheight = parseInt($(window).height())
  headerheight = parseInt(header.css("height")) + parseInt(header.css("padding-top")) + parseInt(header.css("padding-bottom"))
  bodypaddings = parseInt(body.css("padding-top")) + parseInt(body.css("padding-bottom"))
  footerheight = parseInt(footer.css("height")) + parseInt(footer.css("padding-top")) + parseInt(footer.css("padding-bottom"))
  height = windowheight - headerheight - bodypaddings - footerheight - 40 # Top and bottom spacings
  body.css("max-height", "#{height}px")

# Adjust fixed header widths to match the real table widths
window.adjust_table_header_widths = ->
  $(".modal-header #availability_grid_header_fixed").find("thead tr:first-child th").each (i) ->
    $(this).css('min-width':$(".modal-body #availability_grid_table").find("thead tr:first-child th:nth-child("+(i+1)+")").css('width'))

# Adjust width and height of availability grid based on screen size
window.adjust_table_grid_widths = ->
  $("#availability_grid_table td.timeslot").each ->
    if parseInt($(this).css('width')) <= 120
      $(this).closest("tr").find(".room_info").css('width':$(this).css('width'))
      $(this).css('height':$(this).css('width'))
      
# Show and animate progress bar
window.animate_progress_bar = ->
  if (!$("#ajax-modal #remote_progress").is("*")) 
    $("#ajax-modal").find(".modal-header .availability_grid_desc").after($("<div />").attr({'id': 'remote_progress'}).addClass("progress progress-striped active").append($("<div />").addClass("bar").css({width: '5%'})))
    setTimeout ->
      $("#remote_progress > div.bar").css({width: "98%"})
    , 0

# Perform a series of actions when a time slot is clicked on
window.select_room = (clicked_el) ->
  # When a room is selected, show the extra fields with highlight
  $('#ajax-modal').on "change", '.ajax_form input[name="reservation[room_id]"]', (event) ->
    if $('#ajax-modal').find(".ajax_form input[name='reservation[room_id]']").is(':checked')
      $('#ajax-modal').find(".modal-footer input#reservation_cc").animate({backgroundColor: '#f2dede'}, 1000);
      $(".cc").focus()
      fit_modal_body($("#ajax-modal"))
  # Remove any current selected timeslot classes
  $(".timeslot_selected").removeClass("timeslot_selected")
  # Unbind previous click element on every select
  $("#ajax-modal").find(".modal-footer").find("button[type='submit']").addClass("disabled").unbind "click"
  # Reset room info font weight each select as well
  $(clicked_el).closest("table").find("td.room_info").css("font-weight":"normal")
  # Make sure none of the clicked timeslots are unavailable
  unless $(clicked_el).closest("tr").find("td.timeslot_preferred.timeslot_unavailable").is("*")
    # Add selected class to clicked time
    $(clicked_el).closest('tr').find("td.timeslot_preferred").addClass("timeslot_selected")
    # Trigger some actions on clicking the reserve submit button
    $("#ajax-modal").find(".modal-footer").find("button[type='submit']").removeClass("disabled").on "click", ->
        animate_progress_bar()
        $("#ajax-modal").find(".modal-footer #reservation_cc").clone().appendTo(".ajax_form")
        $("#ajax-modal").find(".modal-footer #reservation_title").clone().appendTo(".ajax_form")
        $("#ajax-modal").find(".ajax_form").submit()
        $('#ajax-modal').find("#top_of_page").focus()
        $('#ajax-modal').find(".modal-footer .cc").focus()
    $(clicked_el).closest("tr").find("td.room_info").css("font-weight":"bold")
    # Uncheck hidden radio buttons in form
    $(clicked_el).closest('table').find('td:first-child input:radio:checked').prop('checked', false)
    # Check currently clicked hidden radio button
    $(clicked_el).closest('tr').find('td:first-child input:radio[name="reservation[room_id]"]').prop('checked', true)
    # Trigger the change event defined above
    $(clicked_el).closest('tr').find('td:first-child input:radio[name="reservation[room_id]"]').trigger('change')
