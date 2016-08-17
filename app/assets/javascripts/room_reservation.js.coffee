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
  $(".block_datetime").datetimepicker {
    stepMinute: 30,
    minuteMax: 30,
    dateFormat: 'yy-mm-dd'
  }
  $("#room_reservation_which_date").datepicker {
    numberOfMonths: 2,
    minDate: 0,
    dateFormat: 'yy-mm-dd'
  }

  # Set up sortable list for rooms
  $('ul#list_rooms').sortable {
    handle: "i.fa.fa-arrows"
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
    $("#ajax-modal").find(".modal-footer").html($('<button type="button" data-dismiss="modal" class="btn btn-default btn-lg">Cancel</button>'))
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

  $(document).on 'click', ".room_details_link", (e) ->
    e.preventDefault()
    $(this).popover {
      placement: 'right',
      title: null,
      html: true,
      content: $(this).next(".room_details").html(),
      trigger: 'mouseenter'
    }
    $(this).popover('show')
    false

  $(document).on "click", ".cc", (e) ->
    e.preventDefault()
    $(this).popover {
      placement: 'top',
      title: null,
      html: true,
      content: "Required for collaborative rooms",
      trigger: 'focus'
    }
    $(this).popover('show')
    false

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

  $(".modal-body").on "click", ".room_title_text, .room_type_text, .room_size", ->
    unless $(this).closest("tr").find("td.timeslot_preferred.timeslot_unavailable").is("*")
      select_room($(this).closest("tr").find("td.timeslot_preferred"))

  # Make loading bar reappear and animate when remote links or forms are called
  $(document).on "click", "#ajax-modal a[data-remote='true']", ->
    animate_progress_bar()
