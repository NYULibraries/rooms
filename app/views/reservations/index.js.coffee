$("#ajax-modal").find("#remote_progress").remove()
$("#ajax-modal").modal('hide')
$("#main-flashes").html("<%=j render 'common/flash_msg'%>")