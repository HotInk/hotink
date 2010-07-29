$('ol#document_mediafiles .detach').live('ajax:success', function() { $(this).parent().fadeOut(); });	

// Remote pagination
$('.pagination.remote a').live('click', function (e) {
    $(this).callRemote();
    e.preventDefault();
});


//Runs once the page is loaded
$(function(){
	
	// Document page list item select
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
	
	$("ol.documents.selectable li a").click(function(event){
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
