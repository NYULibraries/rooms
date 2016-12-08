# Hide ajax-loader and modal
$("#ajax-modal").find("#remote_progress").remove()
$("#ajax-modal").modal('hide')
# Render page partials
$("#main-flashes").html("<%=j render 'common/flash_msg'%>")
$("#sidebar nav.navbar:last-child").html("<%=j render 'current_reservations'%>")
