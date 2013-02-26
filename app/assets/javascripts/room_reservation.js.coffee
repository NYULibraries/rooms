$ ->
  $(".js_hide").hide()
  popupPreview()

  $(".report_datetime, .block_datetime").datetimepicker {
    stepMinute: 30,
    minuteMax: 30,
    dateFormat: 'yy-mm-dd'
  }
  $('ul#list_rooms').sortable { 
    handle: "i.icon-move"
    update: -> $(this).closest("form").submit()
    opacity: 0.4
    cursor: 'move'
  }
  $( "#room_reservation_which_date" ).datepicker {
    numberOfMonths: 2,
    minDate: 0,
    dateFormat: 'yy-mm-dd'
  }
  $('input#room_reservation_submit').attr("disabled","true")
  $(document).on "change", 'input#room_reservation_which_date', ->
    $('input#room_reservation_submit').removeAttr("disabled")
  $("#new_reservation input#reservation_submit").hide()
  $("form.edit_reservation input#reservation_submit").removeAttr('disabled')
  $("*[type='submit'][data-remote='true']").hide()
  $("button#generate_grid").show()
  $("#show_user").on 'change', "input[type='checkbox']", ->
    $(this).closest("form").submit()
    
  #$modal = $('#ajax-modal')
  #$('.launch_ajax').on 'click', ->
  #  $('body').modalmanager('loading')
  #
  #  setTimeout( ->
  #    $modal.load $(this).closest("form").attr "action", '', ->
  #      modal.modal()
  #  , 1000)
  #
  #$modal.on 'click', '.update', ->
  #  $modal.modal('loading')
  #  setTimeout( ->
  #    $modal
  #      .modal('loading')
  #      .find('.modal-body')
  #        .prepend('<div class="alert alert-info fade in">' +
  #          'Updated!<button type="button" class="close" data-dismiss="alert">&times;</button>' +
  #        '</div>')
  #  , 1000)
    
  #populate_modal = (data, textStatus, jqXHR) -> 
  #  data = $(data)
  #  heading = data.find("h1, h2, h3, h4, h5, h6").eq(0).remove()
  #  $("#modal .modal-header h3").text(heading.text()) if heading
  #  submit = data.find("form input[type=submit]").eq(0).remove()
  #  $("#modal .modal-body").html(data.html())
  #  $("#modal .modal-footer input[type=submit]").remove()
  #  $("#modal .modal-footer").prepend(submit) if submit
  #  $("#modal").modal("show")
  #
  #display_modal = (event) ->
  #  $('body').modalmanager('loading')
  #  event.preventDefault()
  #  $.get(this.href, "", populate_modal, "html")
  #  false
  #  
  #ajax_form_catch = (event) ->
  #  event.preventDefault()
  #  form =  $("#modal form")
  #  $.post(form.attr("action"), form.serialize(), populate_modal, "html")
  #  false
  #
  #$(document).on "click", ".launch_ajax", display_modal
  #$(document).on "click", "#modal .modal-footer input[type=submit]", ajax_form_catch
  #$(document).on "submit", "#modal form", ajax_form_catch

