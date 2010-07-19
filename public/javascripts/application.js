$('ol#document_mediafiles .detach').live('ajax:success', function() { $(this).parent().fadeOut(); });	

// Remote pagination
$('.pagination.remote a').live('click', function (e) {
    $(this).callRemote();
    e.preventDefault();
});


//Runs once the page is loaded
$(function(){
	// Create draggable articles, if present
	$('.documents.draggable li').draggable({ revert: true, containment: "#page_container" });
	
	// Create image preview fancybox
	$(".image_icon").fancybox({
		'titlePosition'		: 'inside',
		'transitionIn'		: 'none',
		'transitionOut'		: 'none'
	});
	
	$("a.modal").fancybox();
	

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
