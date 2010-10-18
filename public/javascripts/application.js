// If console isn't defined, make dummy functions so non-Webkit browsers don't blow up if someone leaves a console.log around.
if (typeof console == "undefined") {
  console = new Object();
  console.log = function() {};
  console.info = function() {};
  console.error = function() {};
}

$('ol#document_mediafiles .detach').live('ajax:success', function() { $(this).parent().fadeOut(); });	

// Remote pagination
$('.pagination.remote a').live('click', function (e) {
    $(this).callRemote();
    e.preventDefault();
});

function selectAll() {
  $('ol.documents.selectable li').addClass('selected');
  $('ol.documents.selectable .select input, .select_all').attr('checked', true);
}

function deselectAll() {
  $('ol.documents.selectable li').removeClass('selected');
  $('ol.documents.selectable .select input, .select_all').attr('checked', false);
}

//Runs once the page is loaded
$(function(){

  // Select all button (with "Select all" text) handling
  $("#article_select_all_button").click(function(event){
    // This is incredibly ugly, but I have no idea how to work around it. Even with event.preventDefault, checkboxes seem to report their toggled state momentarily, hence the reversed handling. Works in Chrome + Firefox as of 10/10/18.
    // Without this code, if they click on the actual checkbox in the button, nothing happens.
    if (event.target.type == "checkbox") {
      if (event.target.checked) {
        selectAll();
      } else {
        deselectAll();
      }
    }
    else {
      if ($("#article_select_all_button").find(".select_all")[0].checked) {
        deselectAll();
      } else {
        selectAll();
      }
    }
  });
  
  $('.select_all').click(function(event){
	  if ($(event.currentTarget).attr('checked')) {
		  $('ol.documents.selectable li').addClass('selected');
		  $('ol.documents.selectable .select input, .select_all').attr('checked', true);
	  } else {
		  $('ol.documents.selectable li').removeClass('selected');
		  $('ol.documents.selectable .select input, .select_all').attr('checked', false);
	  }
  });
	
	$('ol.documents.selectable li').click(function(event){ 
		if ($(event.currentTarget).hasClass('selected')) {
			$(event.currentTarget).removeClass('selected');
			$(event.currentTarget).find('.select input').attr('checked', false);
		} else {
			$(event.currentTarget).addClass('selected');
			$(event.currentTarget).find('.select input').attr('checked', true);
		}
	});
	
	$("ol.documents.selectable li a, ol.documents.selectable li .mediafiles").click(function(event){
	  event.stopPropagation();
	});
	
	// Create draggable articles, if present
	$('.documents.draggable li').draggable({ revert: true, containment: "#page_container" });
	
	// Create image preview fancybox
	$(".image_icon").fancybox({
		'titlePosition'		: 'inside',
		'transitionIn'		: 'none',
		'transitionOut'		: 'none'
	});
	
	$("a.modal").fancybox();
	
	$("#edit_current_user_link").fancybox();
	
	// Article and entry form stuff
	$('.show_schedule').click(function(){
		$('#schedule').slideToggle("fast");
	}); 
	
	$('form .article_publish').click(function(){
		$('#article_status').val('Published');
	});

	$('form .article_unpublish').click(function(){
		$('#article_status').val('');
	});
	
	$('form .article_sign_off').click(function(){
		$('#article_status').val('Awaiting attention');
	});

	$('form .article_revoke_sign_off').click(function(){
		$('#article_status').val('Revoke sign off');
	});
	$('form .entry_publish').click(function(){
		$('#entry_status').val('Published');
	});

	$('form .entry_unpublish').click(function(){
		$('#entry_status').val('');
	});
	
	$("#attach_mediafile_link").fancybox({
		'titlePosition'		: 'inside',
		'transitionIn'		: 'none',
		'transitionOut'		: 'none'
	});
	
	$('#bodytext_preview_link').fancybox({
		'titlePosition'		: 'inside',
		'transitionIn'		: 'none',
		'transitionOut'		: 'none'
	});

	$('#toggle_preview a').live('click', function(event){
		if (!$(this).hasClass('selected')) {
			$('#toggle_preview a').removeClass('selected');
			if ($(this).hasClass('formatted')) {
				$('#toggle_preview a.formatted').addClass('selected');
				$('#wmd-output').hide();
				$('#wmd-preview').show();
			} else {
				$('#toggle_preview a.raw_html').addClass('selected');
				$('#wmd-output').show();
				$('#wmd-preview').hide();
			}
		}
		event.preventDefault();
	});

});
