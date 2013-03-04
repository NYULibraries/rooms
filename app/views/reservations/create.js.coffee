# Hide ajax-loader and modal
$("#ajax-modal").find("#remote_progress").remove()
$("#ajax-modal").modal('hide')
# Render page partials
$("#main-flashses").html("<%=j render 'common/flash_msg'%>")
$("#reservations_sidebar").html("<%=j render 'current_reservations'%>")