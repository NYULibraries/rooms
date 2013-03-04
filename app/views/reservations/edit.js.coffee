# Hide ajax-loader
$("#ajax-modal").find(".modal-body .ajax-loader").hide()
# Load edit into HTML
$("#ajax-modal").find(".modal-body .modal-body-content").html('<%=j render :partial => "edit"%>')
# Show modal-content-body
$("#ajax-modal").find(".modal-body .modal-body-content").show()
# Find headers and repopulate modal-title
$("#ajax-modal").find(".modal-title").html($("#ajax-modal").find(".modal-body .modal-body-content").find("h1"))
# Move submit action to modal-footer and set to remotely submit form
$("#ajax-modal").find(".modal-footer").append $("#ajax-modal .ajax_form").find("button[type='submit']").addClass("btn-large btn-primary").on "click", ->
  $("#ajax-modal").find(".ajax_form").submit()