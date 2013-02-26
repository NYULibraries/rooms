$ ->
  $('input#room_reservation_submit').attr("disabled","true")
  $('input#room_reservation_which_date').live "change", ->
		$('input#room_reservation_submit').removeAttr("disabled")
  $("#new_reservation input#reservation_submit").hide();
  // Make edit_reservation submit button enabled by default
  $("form.edit_reservation input#reservation_submit").removeAttr('disabled');
  // Initialize image preview plugin
  popupPreview
  
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// AJAX loader image
var $loading = jQuery('<img src="https://library.nyu.edu/images/ajax-loader.gif" alt="loading" id="indicator" class="indicator" />');

// If root, leave blank
var $app_root = "/reserve";

var $sidebar_dialog = jQuery("<div />").attr("id","sidebar_dialog");

var $jqXHRList = [];

jQuery(document).ready(function() {
	
		/* Initialize javascript */
		
		// init popup tip plugin
		jQuery(".tip-simple").nyulibrary_popup_tip("init", {'floatIt':false});
		
		// Hide things unnecessary to JS
		jQuery('.js_hide').hide();
		// Disable 'determine availability' button		
		jQuery('input#room_reservation_submit').attr("disabled","true");
		jQuery('input#room_reservation_which_date').live("change", function() {
			jQuery('input#room_reservation_submit').removeAttr("disabled");
		})
		// Disable 'reserve selected timeslot' button
		jQuery("#new_reservation input#reservation_submit").hide();
		// Make edit_reservation submit button enabled by default
		jQuery("form.edit_reservation input#reservation_submit").removeAttr('disabled');
		// Initialize image preview plugin
		popupPreview();
		
		/* Date picker initializers */
		
		//Datetime picker config		
		jQuery("#room_reservation_which_date").datepicker({
			numberOfMonths: 2,
			minDate: 0
		});
		
		//Datetime picker config		
		jQuery(".block_datetime").datetimepicker({
			minDate: 0,
			stepMinute: 30,
			minuteMax: 30
		});
		jQuery(".report_datetime").datetimepicker({
			stepMinute: 30,
			minuteMax: 30
		});
	
		jQuery(".calendar_image_link").click(function(event) {
			event.preventDefault();
			jQuery(this).prev("input").focus();
		});
		
		/* Create AJAX versions of links in the grid popup with key make_link_remote */
		jQuery('#ajax_module a.make_link_remote').live("click", function(event) {
			event.preventDefault();
			
			$link = jQuery(this);
			
			jQuery("#ajax_module").prepend($loading.clone());

			jQuery.ajax({
				type: "GET",
				url: $link.attr("href"),
				success: function(data, textStatus, jqXHR) {
					jQuery("#ajax_module").html(data);
					initialize_availability_grid();			
				}
			});
		});
		
		
		/* Create AJAX versions of links in the sidebar with key make_link_remote */
		jQuery('#reservations_sidebar a.make_link_remote').live("click", function(event) {
			event.preventDefault();
			
			$link = jQuery(this);
			
			$sidebar_dialog.html($loading.clone());
			
			if ($link.attr("data-http-method").toUpperCase() == "DELETE") {
				jQuery("<div />").dialog({
					title: "<img src=\"https://library.nyu.edu/images/famfamfam/error.png\" /> Are you sure?",
					width: 300,
					height: 150,
					position: 'center',
					modal: true,
					resizable: false,
					buttons: {
						'Oops! No.': function() { jQuery(this).dialog('close'); return false; },
						'Yes, delete it.': function() { jQuery(this).dialog('close'); make_sidebar_links_remote($link); }
					}
				}).html(" Are you sure you want to delete this reservation permanently?");
				
			} else {
				make_sidebar_links_remote($link);
			}	
			
		});
		
		/* Create ajax versions of forms loaded in sidebar dialog */
		jQuery('#sidebar_dialog form.make_form_remote').live("submit", function(event) {
			event.preventDefault();
			
			$form = jQuery(this);
			
			$sidebar_dialog.html($loading.clone());

			jQuery.ajax({
				type: $form.attr("data-http-method").toUpperCase(),
				url: $form.attr("action"),
				data: $form.serialize(),
				success: function(data, textStatus, jqXHR) {
					$sidebar_dialog.html(data);	
				}
			});
		});
		
		/* Create AJAX version of the reservation creation form */
		jQuery('#generate_grid_form').live("submit", function(event) {
			event.preventDefault();
			
			// Load the dialog with a loading indicator image
			jQuery("#ajax_module").html($loading.clone());
			
			/* The remote form for generating the availability grid */			
			$form = jQuery(this);
			$data = $form.serialize();
			$request = jQuery.ajax({
				url: $form.attr("action"),
				data: $data,
				success: function(data, textStatus, jqXHR) {
					jQuery("#ajax_module").html(data);
					jQuery("#ajax_module").dialog({
						minWidth: jQuery(window).width() * .9,
						height: jQuery(window).height() - 10,
						position: [jQuery(window).width() * .05,'top'],
						modal: true
					});
					jQuery("#ajax_module").dialog('open');
					//Call setup functions
					setup_availability_grid_fields();
					initialize_availability_grid();
				},
				error: function(jqXHR, textStatus, errorThrown) {
					jQuery("#ajax_module").dialog('destroy');
					jQuery("#ajax_module").html(jqXHR.responseText);
					jQuery("#ajax_module").dialog({
						title: 'Error',
						width: 500,
						height: 250,
						position: 'center',
						modal: true
					});
					jQuery("#ajax_module").dialog('open');
					//Call setup functions
					initialize_availability_grid();
				}
			});
			
			/* Create the dialog box that the availability grid will load in */
			jQuery("#ajax_module").dialog({
				title: 'Availability',
				height: 250,
				width: 500,
				modal: true,
				position: 'center',
				hide: "fade",
				show: "fade",
				buttons: {
					Cancel: function() { jQuery(this).dialog('close'); },
					'Reserve selected timeslot': function() { reserve_selected_timeslot(); }
				},
				close: function() {
					$request.abort();
					jQuery(this).dialog('destroy');
				}
			});
			jQuery("#ajax_module").dialog('open');
			
		});
		
		/* Perform actions on dialog close */
		jQuery(".close_dialog").live("click", function(event) {
			event.preventDefault();
			jQuery("#ajax_module").dialog('destroy');
			jQuery("input[name='room_reservation[which_date]']").focus();
			jQuery("#generate_grid_form > table.grayborder").effect("highlight", {}, 3000);
		});		
		
		// prevent "enter" keypress from submitting the form
		jQuery("#new_reservation").live("submit",function(event) {
			event.preventDefault();
			if (jQuery("input[name='reservation[room_id]']").is(':checked')) {
				reserve_selected_timeslot();
			}
		});

		// when a room is selected, show the extra fields with animation and highlight
		jQuery('input[name="reservation[room_id]"]').live("change",function(event) {
			if (jQuery("input[name='reservation[room_id]']").is(':checked') && jQuery("#append_fields").is(':hidden')) {
				jQuery("#append_fields").show();
				jQuery("#ajax_module").animate({
				    height: '-=' + (jQuery("#append_fields").height() + 50)
				}, 200, function() {	
						jQuery("input#reservation_title").focus();
						jQuery("input#reservation_title").effect("highlight", {}, 3000);
				});
				
			}
		});
		
		/* Admin JS functions */
		make_rooms_sortable();
		update_admin_status_remotely();	
		refresh_images_list();
		
});

/**
	Preprocess fields to be appended to availability grid
	*/
function setup_availability_grid_fields() {
	$append_fields = jQuery("<div />").attr("id","append_fields");
	// Clone event title and CCs fields and append them onto the form
	$res_title_container = jQuery("<div />").attr("id","res_title_container");
	$res_cc_container = jQuery("<div />").attr("id","res_cc_container");
	$res_title_container.append(jQuery("#res_title_label_div").clone());
	$res_title_container.append(jQuery("#res_title_div").clone());				
	$res_cc_container.append(jQuery("#res_cc_label_div").clone());
	$res_cc_container.append(jQuery("#res_cc_div").clone());
	$append_fields.wrap("<form action=\"#\" method=\"post\" />");
	// Add form at the end of popup, but before the submit buttons
	jQuery("#ajax_module").after($append_fields.append($res_title_container).append($res_cc_container).hide());
	// Make call to remove the cloned fields from the original form
	remove_availability_grid_form_fields();
}

/**
	Remove fields from availability grid, probably because they've been cloned by above function
	*/
//function remove_availability_grid_form_fields() {
//	jQuery("#ajax_module #res_title_label_div").remove();
//	jQuery("#ajax_module #res_cc_label_div").remove();
//	jQuery("#ajax_module #res_title_div").remove();
//	jQuery("#ajax_module #res_cc_div").remove();
//}

/**
	Remotely refresh select options with room images
	
function refresh_images_list() {

	jQuery("a.refresh_images_list").click(function(event) {
			//Find the room id
			if (jQuery(this).closest("form").find("input#room_room_id").attr("value") != undefined)	{
				room_id = jQuery(this).closest("form").find("input#room_room_id").attr("value");
			} else {
				room_id = "";
			}
			
		event.preventDefault();
		jQuery.ajax({
			url: $app_root + "/rooms/refresh_images_list",
			type: "POST",
			data: "id="+room_id,
			beforeSend: function() {
				jQuery("#images_list").append($loading.clone());
			},
			success: function(data,textStatus,jqXHR) {
				jQuery("#images_list").html(data);
			}
		});
	});
}*/

/**
	Send AJAX request when reservation was selected from availability grid
	*/
function reserve_selected_timeslot() {
	// Check to see if a room was selected
	if (jQuery("input[name='reservation[room_id]']").is(':checked')) {
	// Serialize fields
	$data = jQuery("#new_reservation").serializeArray();
	// Append extra fields not inside the actual form
	$data.push({name: "reservation[cc]", value: jQuery("#reservation_cc").attr("value")});
	$data.push({name: "reservation[title]", value: jQuery("#reservation_title").attr("value")});

	// ajax post call
	$reserve = jQuery.ajax({
		type: "POST",
		url: jQuery("#new_reservation").attr("action"),
		data:	jQuery.param($data),
		beforeSend: function() {
			jQuery("#ajax_module").html($loading.clone());
		},
		success: function(data, textStatus, jqXHR) {
			// on success: update current reservations in sidebar
			update_current_reservations();
			// Close current dialog
			jQuery("#ajax_module").dialog('destroy');
			// And reopen with success message
			jQuery("#ajax_module").html(data);
			jQuery("#ajax_module").dialog({
				title: "Success!",
				height: 250,
				width: 500,
				position: 'center',
				modal: true
			});
			jQuery("#ajax_module").dialog('open');
			// Setup availability grid for another potential call
			initialize_availability_grid();
		},
		error: function(jqXHR, textStatus, errorThrown) {
			// on error: populate dialog with error text
			jQuery("#ajax_module").html(jqXHR.responseText);
			// Setup availability grid for another call
			initialize_availability_grid();
		}
	});
	}
}

/**
	When javascript is enabled, unobtrusively make the action links in the sidebar ajax call
	*/
//function make_sidebar_links_remote($link) {
//	$sidebar_request = jQuery.ajax({
//		type: $link.attr("data-http-method").toUpperCase(),
//		url: $link.attr("href"),
//		success: function(data, textStatus, jqXHR) {
//			$sidebar_dialog.html(data);	
//		}
//	});
//
//	$sidebar_dialog.dialog({
//		title: $link.attr("title"),
//		width: 500,
//		height: 250,
//		position: 'center',
//		modal: true,
//		close: function() {
//			$sidebar_request.abort();
//			update_current_reservations();
//		}
//	});
//	$sidebar_dialog.dialog('open');
//}

/**
	Update the current reservations list in the sidebar remotely
	
function update_current_reservations() {
	jQuery.ajax({
		url: $app_root + "/reservations/update_current_reservations",
		type: "POST",
		beforeSend: function() {
			jQuery("#current_reservations").append($loading.clone());
		},
		success: function(data,textStatus,jqXHR) {
			jQuery("#reservations_sidebar").html(data);
		}
	});
}*/

/** 
	Disable the availability grid registration form if no date is selected
	*/
//function initialize_availability_grid() {
//	// hide the submit button only used for non-JS browsers
//	jQuery("#new_reservation input#reservation_submit").hide();
//	// disable the optional title field until...
//	//jQuery("#new_reservation input#reservation_title").attr("disabled","true");
//	// ...a date is selected
//	remove_availability_grid_form_fields();
//	jQuery(".tip-simple").nyulibrary_popup_tip("init", {'floatIt':false});
//}

/** 
	Make the admin function "rooms list" a sortable jQuery list
	*/
//function make_rooms_sortable() {
//	var move = jQuery("<img />").attr({src: $app_root + '/images/move.png'});
//	jQuery("form#rooms_form input[type='text']").before(move);
//	
//	jQuery(function() {
//		jQuery( "#list_rooms" ).sortable({
//			placeholder: "ui-state-highlight",
//			update: function() {
//			  jQuery.post(jQuery(this).closest("form").attr("action"), jQuery(this).sortable('serialize'));
//			}
//		});
//		jQuery( "#list_rooms" ).disableSelection();
//	});
//}

/** 
	Make the toggle admin functionality in the patron view an AJAX function, just cuz
	*/
//function update_admin_status_remotely() { 
//	jQuery("#patron_is_admin").change(function(event) {
//		event.preventDefault();
//		jQuery.ajax({
//			url: jQuery(this).closest("form").attr("action"),
//			data: jQuery(this).closest("form").serializeArray()
//		});
//	});
//	jQuery("#patron_submit").hide();
//}

