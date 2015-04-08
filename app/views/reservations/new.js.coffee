<% if flash[:error] %>

$("#ajax-modal #remote_progress").remove()
$("#ajax-modal").find(".modal-body .ajax-loader").hide()
$("#ajax-modal").modal 'hide'
$("#main-flashses").html("<%=j render 'common/flash_msg'%>")

<% else %>

# Hide ajax-loader
$("#ajax-modal #remote_progress").remove()
$("#ajax-modal").find(".modal-body .ajax-loader").hide()

# Load edit into HTML
$("#ajax-modal").find(".modal-body .modal-body-content").html('<%=j render :partial => "new" %>')

# Show modal-content-body
$("#ajax-modal").addClass("fullscreen")
$("#ajax-modal").find(".modal-body .modal-body-content").show()

# Find headers and repopulate modal-title
$("#ajax-modal").find(".modal-title").html($("#ajax-modal").find(".modal-body .modal-body-content").find(".availability_grid_desc"))
$("#ajax-modal").find(".modal-body .modal-body-content").find("h1.page_title").hide()

# Move submit action to modal-footer and set to remotely submit form
if (!$("#ajax-modal").find(".modal-footer button[type='submit']").is("*"))
  $("#ajax-modal").find(".modal-footer").append $("#ajax-modal .ajax_form").find("button[type='submit']").addClass("btn-lg btn-primary disabled").on 'click', ->
    false

#Move extra fields in availability grid to modal-footer, just pretties it up a bit
$("#ajax-modal").find(".ajax_form table tfoot").hide()

if (!$("#ajax-modal").find(".modal-footer .extra_fields").is("*"))
  $("#ajax-modal").find(".modal-footer").prepend($("#ajax-modal .ajax_form").find(".extra_fields div"))
  $("#ajax-modal").find(".modal-footer div").wrapAll($("<div />").addClass("extra_fields"))
  $("#ajax-modal").find(".modal-footer").find("#res_title_label_div, #res_title_div").wrapAll($("<div />").addClass("extra_field"))
  $("#ajax-modal").find(".modal-footer").find("#res_cc_label_div, #res_cc_div").wrapAll($("<div />").addClass("extra_field"))

  # Set labels as placeholder text inside inputs
  $("#ajax-modal").find("#reservation_cc").attr("placeholder", $("#ajax-modal").find("#res_cc_label_div").text())
  $("#ajax-modal").find("#reservation_title").attr("placeholder", $("#ajax-modal").find("#res_title_label_div").text())
  $("#ajax-modal").find("#res_title_label_div, #res_cc_label_div").hide()

# Move legend into header region
$("#ajax-modal").find(".modal-header").append($("#ajax-modal").find(".modal-body .legend:first")) if !$("#ajax-modal").find(".modal-header .legend").is("*")

# Move availability grid description into header region
$("#ajax-modal").find(".modal-header").append($("#ajax-modal").find(".modal-body .availability_grid_desc")) if !$("#ajax-modal").find(".modal-header .availability_grid_desc").is("*")

# Then hide original elements from modal body
$("#ajax-modal").find(".modal-body").find(".legend, .availability_grid_desc").hide()

# Show extra fields in footer if the form was reloaded and there is a room checked
if $('#ajax-modal').find(".ajax_form input[name='reservation[room_id]']").is(':checked') && $("#ajax-modal").find(".modal-footer .extra_fields").is(':hidden')
	$('#ajax-modal').find(".modal-footer .extra_fields").show()

# Scrollback to top of page to avoid any offset weirdness
# And remove previous fixed headers
$(".modal-body").animate({ scrollTop: 0 }, 0)
$(".modal-header").find("#availability_grid_header_fixed").remove()

# Fit modal to screen size after all other resizings have been done
fit_modal_body($("#ajax-modal"))

# Varriable for affixing table header
tableOffset = $(".modal-body #availability_grid_table tbody").position().top
header = $("#availability_grid_table > thead").clone()
fixedHeader = $("#availability_grid_header_fixed").append(header).hide()
$(".modal-header").append(fixedHeader)

# Bind actions to the scroll event
$(".modal-body").bind "scroll", ->
  offset = $(this).scrollTop()
  $(".modal-header").prop("scrollLeft", $(this).scrollLeft())

  # Show fixedHeader when scrolling down table
  if (offset >= tableOffset && fixedHeader.is(":hidden"))
    fixedHeader.show()
    adjust_table_header_widths()
    fit_modal_body($("#ajax-modal"))
  # And hide when back at the top
  else if (offset < tableOffset)
    fixedHeader.hide()
    fit_modal_body($("#ajax-modal"))

$("#availability_grid_table").find("input:radio:checked").closest("tr").find("td.timeslot_preferred").addClass("timeslot_selected")

# Hide radio buttons
$("#availability_grid_table, #availability_grid_header_fixed").find(".hide_radio").hide()

$("#availability_grid_table").find("td.timeslot_preferred.timeslot_unavailable").closest("tr").addClass("disabled_row")

# Initially set height for wide-view windows
$("#availability_grid_table td.timeslot").css("height","120px")

# Trigger scroll and resize events
$(".modal-body").scroll()
$(window).resize()

<% end %>
