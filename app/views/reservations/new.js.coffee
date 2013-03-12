<% if flash[:error] %>
$("#main-flashses").html("<%=j render 'common/flash_msg'%>")
$("#ajax-modal #remote_progress").remove()
$("#ajax-modal").find(".modal-body .ajax-loader").hide()
$("#ajax-modal}").modal('hide')
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
$("#ajax-modal").find(".ajax_form table tbody tr:last").hide()
$("#ajax-modal").find(".ajax_form .extra_fields").closest("tr").hide()
if (!$("#ajax-modal").find(".modal-footer .extra_fields").is("*")) 
  $("#ajax-modal").find(".modal-footer").prepend($("#ajax-modal .ajax_form").find(".extra_fields div"))
  $("#ajax-modal").find(".modal-footer div").wrapAll($("<div />").addClass("extra_fields"))
  $("#ajax-modal").find(".modal-footer").find("#res_title_label_div, #res_title_div").wrapAll($("<div />").addClass("extra_field"))
  $("#ajax-modal").find(".modal-footer").find("#res_cc_label_div, #res_cc_div").wrapAll($("<div />").addClass("extra_field"))
$("#ajax-modal").find(".modal-footer .extra_fields").hide();
# When a room is selected, show the extra fields with animation and highlight
$('#ajax-modal').find('.ajax_form input[name="reservation[room_id]"]').on "change", (event) ->
  if ($('#ajax-modal').find(".ajax_form input[name='reservation[room_id]']").is(':checked') && $("#ajax-modal").find(".modal-footer .extra_fields").is(':hidden')) 
    $('#ajax-modal').find(".modal-footer .extra_fields").show()
    $("#ajax-modal").find(".modal-body").animate {
      height: '-=' + $("#ajax-modal").find(".modal-footer .extra_fields").height()
    }, 200, ->
    $('#ajax-modal').find(".modal-footer input#reservation_title").focus()
    $('#ajax-modal').find(".modal-footer input#reservation_title").effect("highlight", {}, 3000)
# Make loading bar reappear and animate when remote links or forms are called
$("#ajax-modal").find("a[data-remote='true'], .modal-footer button[type='submit']").on "click", ->
  if (!$("#ajax-modal #remote_progress").is("*")) 
    $("#ajax-modal").find(".modal-header").append($("<div />").attr({'id': 'remote_progress'}).addClass("progress progress-striped active").append($("<div />").addClass("bar").css({width: '5%'})))
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
# Resize the modal dialog back to original size when remote form or links are submitted
# This stops the dialog from continuous shrinking after this is rerendered without changing 
# the size and another room is selected calling the above animation code to adjust size for extra fields
$("#ajax-modal").find("a[data-remote='true'], .modal-footer button[type='submit']").on 'click', ->
  $('#ajax-modal').find(".modal-footer .extra_fields").hide()
  $("#ajax-modal").find(".modal-body").animate {
    height: '+=' + $("#ajax-modal").find(".modal-footer .extra_fields").height()
  }, 200
# Fit modal to screen size after all other resizings have been done
fit_modal_body($("#ajax-modal"))
<% end %>
