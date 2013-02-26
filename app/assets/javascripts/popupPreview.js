/*
 * Image preview script 
 * powered by jQuery (http://www.jquery.com)
 * 
 * written by Alen Grakalic (http://cssglobe.com)
 * updated by Barnaby Alter (http://library.nyu.edu) 2011-07
 * 	- added .live() capability
 * 
 * for more info visit http://cssglobe.com/post/1695/easiest-tooltip-and-image-preview-using-jquery
 *
 */

this.popupPreview = function(){	
	/* CONFIG */
		
		xOffset = 10;
		yOffset = 30;
		
		// these 2 variable determine popup's distance from the cursor
		// you might want to adjust to get the right result
		
	/* END CONFIG */
	jQuery(document).on('mouseenter', "a.previewImage", function(e){
		this.t = this.title;
		this.title = "";	
		var c = (this.t != "") ? "<br/>" + this.t : "";
		jQuery("body").append("<p id='preview'><img src='"+ this.href +"' alt='Image preview' />"+ c +"</p>");								 
		jQuery("#preview")
			.css("top",(e.pageY - xOffset) + "px")
			.css("left",(e.pageX + yOffset) + "px")
			.fadeIn("fast");						
  });

	jQuery(document).on('mouseenter', "a.previewLink", function(e){
		this.t = this.title;
		this.title = "";	
		var c = (this.t != "") ? this.t : "";
		jQuery("body").append("<p id='preview'>"+ c +"</p>");								 
		jQuery("#preview")
			.css("top",(e.pageY - xOffset) + "px")
			.css("left",(e.pageX + yOffset) + "px")
			.fadeIn("fast");						
  });

	jQuery(document).on('mouseleave', "a.preview", function(e){
		this.title = this.t;	
		jQuery("#preview").remove();
  });

	jQuery(document).on('mousemove', "a.preview", function(e){
		jQuery("#preview")
			.css("top",(e.pageY - xOffset) + "px")
			.css("left",(e.pageX + yOffset) + "px");
	});			
};