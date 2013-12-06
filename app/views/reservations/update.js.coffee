$("#ajax-modal").modal('hide')
$("#main-flashses").html("<%=j render 'common/flash_msg'%>")
$("#sidebar div.navbar:last-child").html("<%=j render 'current_reservations'%>")