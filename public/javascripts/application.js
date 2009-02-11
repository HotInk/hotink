// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//Function below handle adding and removing default text from form text input elements
function clearText(theField)
{
if (theField.defaultValue == theField.value)
theField.value = '';
}

function addText(theField)
{
if (theField.value == '')
theField.value = theField .defaultValue;
}


//Article form nested object creation code

var new_sorting_count = 1;

function new_article_sorting(category_id, caller)
{
	$('article_form_hidden_elements').insert(new Element('input', { 'type':'hidden', 'id':('article_sortings_attributes_new_' + new_sorting_count + '_category_id'), 'name':('article[sortings_attributes][new_' + new_sorting_count + '][category_id]'), 'value':category_id}));
	$(caller).writeAttribute("onclick", "delete_new_article_sorting(" + new_sorting_count + ", " + category_id + ", this)");
	new_sorting_count = new_sorting_count + 1;
	
}

function delete_new_article_sorting(new_sorting_id, category_id, caller)
{
	Element.remove('article_sortings_attributes_new_' + new_sorting_id + '_category_id');
	$(caller).writeAttribute("onclick", "new_article_sorting(" + category_id + ", this)");
}

function mark_sorting_for_delete(sorting_id, caller) {
	$("article_sortings_attributes_" + sorting_id + "__delete").value = "1";
	$(caller).writeAttribute("onclick", "unmark_sorting_for_delete(" + sorting_id + ", this)");
}

function unmark_sorting_for_delete(sorting_id, caller) {
	$("article_sortings_attributes_" + sorting_id + "__delete").value = "0";
	$(caller).writeAttribute("onclick", "mark_sorting_for_delete(" + sorting_id + ", this)");
}

//Article form tag-management code

function adjust_tag_list(new_tag_list) {
	if (new_tag_list==""||new_tag_list=="Add tags here"){
		return false;
	} 
	else if ( $F('article_tag_list')=="" ) {
		var value = new_tag_list
	}
	else {
		var value = $F('article_tag_list').split(",").concat(new_tag_list.split(",")).join(",");
	}
	$('article_tag_list').writeAttribute("value", value );
}