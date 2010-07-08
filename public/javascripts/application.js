$('ol#article_mediafiles .detach').live('ajax:success', function() { $(this).parent().fadeOut(); });	

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

// Remote pagination
$('.pagination.remote a').live('click', function (e) {
    $(this).callRemote();
    e.preventDefault();
});

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
});


