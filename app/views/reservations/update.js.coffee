$("#ajax-modal").modal('hide')
$("#main-flashses").html("<%=j render 'common/flash_msg'%>")
$("#sidebar nav.navbar:last-child").html("<%=j render 'current_reservations'%>")
