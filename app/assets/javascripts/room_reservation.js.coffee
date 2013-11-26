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
  
window.adjust_table_header_widths = ->
  $(".modal-header #availability_grid_header_fixed").find("thead tr:first-child th").each (i) ->
    $(this).css('min-width':$(".modal-body #availability_grid_table").find("thead tr:first-child th:nth-child("+(i+1)+")").css('width'))

window.adjust_table_grid_widths = ->
  $("#availability_grid_table td.timeslot").each ->
    if parseInt($(this).css('width')) <= 120
      $(this).css('height':$(this).css('width'))
      $(this).closest("tr").find(".room_info").css('width':$(this).css('width'))

window.animate_progress_bar = ->
  if (!$("#ajax-modal #remote_progress").is("*")) 
    $("#ajax-modal").find(".modal-header .availability_grid_desc").after($("<div />").attr({'id': 'remote_progress'}).addClass("progress progress-striped active").append($("<div />").addClass("bar").css({width: '5%'})))
    setTimeout ->
      $("#remote_progress > div.bar").css({width: "98%"})
    , 0

window.select_room = (clicked_el) ->
  # When a room is selected, show the extra fields with highlight
  $('#ajax-modal').on "change", '.ajax_form input[name="reservation[room_id]"]', (event) ->
    if ($('#ajax-modal').find(".ajax_form input[name='reservation[room_id]']").is(':checked') && $("#ajax-modal").find(".modal-footer .extra_fields").is(':hidden')) 
      $('#ajax-modal').find(".modal-footer .extra_fields").show()
      $('#ajax-modal').find(".modal-footer input#reservation_title").focus()
      $('#ajax-modal').find(".modal-footer input#reservation_title").effect("highlight", {}, 3000)
      fit_modal_body($("#ajax-modal"))
  $(".timeslot_selected").removeClass("timeslot_selected")
  unless $(clicked_el).closest("tr").find("td.timeslot_preferred.timeslot_unavailable").is("*")
    $(clicked_el).closest('tr').find("td.timeslot_preferred").addClass("timeslot_selected")
    $("#ajax-modal").find(".modal-footer").find("button[type='submit']").removeClass("disabled").on "click", ->
        animate_progress_bar()
        $("#ajax-modal").find(".modal-footer #reservation_cc").clone().appendTo(".ajax_form")
        $("#ajax-modal").find(".modal-footer #reservation_title").clone().appendTo(".ajax_form")
        $("#ajax-modal").find(".ajax_form").submit()
        $('#ajax-modal').find("#top_of_page").focus()
    $(clicked_el).closest('table').find('td:first-child input:radio:checked').prop('checked', false)
    $(clicked_el).closest('tr').find('td:first-child input:radio[name="reservation[room_id]"]').prop('checked', true)
    $(clicked_el).closest('tr').find('td:first-child input:radio[name="reservation[room_id]"]').trigger('change')
  else
    $("#ajax-modal").find(".modal-footer").find("button[type='submit']").addClass("disabled").unbind "click"

$ ->
  # Set cookie finding user's timezone
  detected_zone = Temporal.detect()
  
  # Hide objects not important for JS
  $(".js_hide").hide()
  
  # Disable anchor tags linking to #
  $(document).on "click", "a[href='#']", ->
    false

  # Click the calendar icon to select a date
  $(document).on 'click', "a.select_date_icon", (e) ->
    e.preventDefault()
    $('#room_reservation_which_date').focus()

  # Set up date picker objects
  $(".report_datetime, .block_datetime").datetimepicker {
    stepMinute: 30,
    minuteMax: 30,
    dateFormat: 'yy-mm-dd'
  }
  $( "#room_reservation_which_date" ).datepicker {
    numberOfMonths: 2,
    minDate: 0,
    dateFormat: 'yy-mm-dd'
  }
  
  # Set up sortable list for rooms
  $('ul#list_rooms').sortable {
    handle: "i.icon-move"
    update: -> $(this).closest("form").submit()
    opacity: 0.4
    cursor: 'move'
  }
  
  # Set date picker for reservation date to readonly and autocomplete off
  $("#room_reservation_which_date").attr {
    "readonly": "true",
    "autocomplete": "off"
  }
  
  # Disable main form submit if no date was selected
  # And then enable once it is
  $('button#generate_grid').attr("disabled","true")
  $(document).on "change", 'input#room_reservation_which_date', ->
    $('button#generate_grid').removeAttr("disabled")
    
  # Submit edit user form when admin checkbox is changed
  $("#show_user").on 'change', "input[type='checkbox']", ->
    $(this).closest("form").submit()
  
  # Initialize modal dialog boxes
  $(document).on 'click', ".launch_modal", ->
    $("#ajax-modal").removeClass("fullscreen")
    $("#ajax-modal").find(".modal-footer").html($('<button type="button" data-dismiss="modal" class="btn btn-large">Cancel</button>'))
    $("#ajax-modal").find(".modal-title").html("Loading...")
    $("#ajax-modal").find(".modal-header").find(".legend, p").remove()
    $("#ajax-modal").find(".modal-body-content").html('')
    $("#ajax-modal").find(".modal-body").removeAttr("style")
    $("#ajax-modal").find(".ajax-loader").show()
    $("#ajax-modal").modal('show')
    window.location.hash = '#reservations'
    
  $(window).on 'hashchange', ->
    if window.location.hash != '#reservations'
      $("#ajax-modal").modal('hide')
  
  $(document).on 'click', "#ajax-modal a.close_dialog", (e) ->
    e.preventDefault()
    $("#ajax-modal").modal('hide')
    $("#room_reservation_which_date").focus()
    $("#room_reservation_which_date").effect("highlight", {}, 3000)
    false
  
  # Setup popup for classroom images
  $(document).on 'mouseenter', ".preview_image", ->
    $(this).popover {
      placement: 'right',
      title: null,
      html: true,
      content: '<img class="preview" src="' +this+ '" />',
      trigger: 'hover',
    }
    $(this).popover('show')
   
  # Set tooltips for booking information on grid
  $(document).on 'mouseenter', ".preview_link", ->
    $(this).tooltip {
      placement: 'bottom',
      trigger: 'hover',
    }
    $(this).tooltip('show')

  # Bind resize event with the modal
  $(window).resize ->
    fit_modal_body($("#ajax-modal"))
    adjust_table_header_widths()
    adjust_table_grid_widths()

  # Make preferred slot selectable by clicking table
  $(".modal-body").on "click", "td.timeslot_preferred", ->
    select_room(this)
    
  # Make loading bar reappear and animate when remote links or forms are called
  $(document).on "click", "#ajax-modal a[data-remote='true']", ->
    animate_progress_bar()
   