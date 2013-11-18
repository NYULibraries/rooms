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
$("#ajax-modal").find(".modal-title").html($("#ajax-modal").find(".modal-body .modal-body-content").find("h1"))

# Move submit action to modal-footer and set to remotely submit form
if (!$("#ajax-modal").find(".modal-footer button[type='submit']").is("*")) 
  $("#ajax-modal").find(".modal-footer").append $("#ajax-modal .ajax_form").find("button[type='submit']").addClass("btn-large btn-primary").on "click", ->
    $("#ajax-modal").find(".modal-footer #reservation_cc").clone().appendTo(".ajax_form")
    $("#ajax-modal").find(".modal-footer #reservation_title").clone().appendTo(".ajax_form")
    $("#ajax-modal").find(".ajax_form").submit()
    $('#ajax-modal').find("#top_of_page").focus()
    
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

#And Initially hide extra fields
$("#ajax-modal").find(".modal-footer .extra_fields").hide();

# When a room is selected, show the extra fields with highlight
$('#ajax-modal').on "change", '.ajax_form input[name="reservation[room_id]"]', (event) ->
  if ($('#ajax-modal').find(".ajax_form input[name='reservation[room_id]']").is(':checked') && $("#ajax-modal").find(".modal-footer .extra_fields").is(':hidden')) 
    $('#ajax-modal').find(".modal-footer .extra_fields").show()
    $('#ajax-modal').find(".modal-footer input#reservation_title").focus()
    $('#ajax-modal').find(".modal-footer input#reservation_title").effect("highlight", {}, 3000)
    fit_modal_body($("#ajax-modal"))

# Make loading bar reappear and animate when remote links or forms are called
$("#ajax-modal").on "click", "a[data-remote='true'], .modal-footer button[type='submit']", ->
  if (!$("#ajax-modal #remote_progress").is("*")) 
    $("#ajax-modal").find(".modal-header .availability_grid_desc").append($("<div />").attr({'id': 'remote_progress'}).addClass("progress progress-striped active").append($("<div />").addClass("bar").css({width: '5%'})))
    setTimeout ->
      $("#remote_progress > div.bar").css({width: "98%"})
    , 0
    
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
$(".modal-body").animate({ scrollTop: 0 }, 0);
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

  #if $('.pagination').length
  #  if offset >= $('.modal-body-content').height() - $(window).height() - 50
  #    url = $('.pagination .next a').attr('href')
  #    if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
  #      $('.pagination').text("Fetching more products...")
  #      sleep 1
  #      $.getScript url, ( data, textStatus, jqxhr ) ->
  #        console.log data
        
$(".modal-body").scroll()

<% end %>
