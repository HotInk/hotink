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
theField.value = theField.defaultValue;
}

// The hack below fixs a browser incosistency with button display.
// Firefox adds 3px margin to the left and right, we need to knock it
// off to match other browsers' display style.
//
// Call this after the page loads buttons
var load_button_fix = function () {
	if(Prototype.Browser.Gecko) $$('button').each(function(bt){bt.setStyle({margin: "0 -3px"});});
}


//Article form nested object creation code

var new_sorting_count = 1;

function new_article_sorting(category_id, caller)
{
	$('category_form_hidden_elements').insert(new Element('input', { 'type':'hidden', 'id':('article_sortings_attributes_new_' + new_sorting_count + '_category_id'), 'name':('article[sortings_attributes][new_' + new_sorting_count + '][category_id]'), 'value':category_id}));
	$(caller).writeAttribute("onclick", "delete_new_article_sorting(" + new_sorting_count + ", " + category_id + ", this)");
	new_sorting_count = new_sorting_count + 1;
	
}

function delete_new_article_sorting(new_sorting_id, category_id, caller)
{
	Element.remove('article_sortings_attributes_new_' + new_sorting_id + '_category_id');
	$(caller).writeAttribute("onclick", "new_article_sorting(" + category_id + ", this)");
}

function mark_sorting_for_delete(sorting_id, category_id, caller) 
{
	$("article_sortings_attributes_" + sorting_id + "__delete").value = "1";
	$(caller).writeAttribute("onclick", "new_article_sorting(" + category_id + ", this)");
}

// Swaping drawer button effect

var swap = function(element1, element2, toggle){
	var drawer1 = $(element1);
	var drawer2 = $(element2);
	var toggle = $(toggle);
	if (!toggle.hasClassName("selected")) {
		new Effect.SlideUp(drawer1, {duration:0.1,queue:'front'});
		new Effect.SlideDown(drawer2, {duration:0.2,queue:'end'});
	} else {
		new Effect.SlideUp(drawer2, {duration:0.2,queue:'front'});
		new Effect.SlideDown(drawer1, {duration:0.1,queue:'end'});
	}
}

// Load category edit functionality
// This is 100% custom functionality and it's pretty complex. 
// It will probably be worthwhile to abstract it as a control, but that'll be a huge job.
// TODO: Abstract category edit functionality for general use as a list/tree-list edit control

var categories_editing = false;
var categories_tree = {};
var load_category_edit = function(){
	
	if (categories_editing) {
		// Hide edit buttons
		$('categories_list').select('li').each(function (item){ item.childElements()[1].childElements()[1].setStyle({visibility:'hidden'})});
		
		categories_tree.setUnsortable();
		new Effect.SlideUp($('hidden_categories_buttons'), {duration:0.1});
		$('categories_list').select('input').each( function (inp){ inp.setStyle({opacity:1.0}); inp.enable(); });
		categories_editing = false;
	} else {
		new Effect.SlideDown($('hidden_categories_buttons'), {duration:0.1});
		
		//Make edit buttons visible
		$('categories_list').select('li').each(function (item){ item.childElements()[1].childElements()[1].setStyle({visibility:'visible'})});
		
		//  Build SortableTree from list items.
		categories_tree = new SortableTree('categories_sort', {
			onDrop: function(drag, drop, event){
					
					//Count upwards looking for siblings until we hit null, that's our drop point.
					var drop_position = 1;
					var root_node_check = drag.previousSibling();	
					while (root_node_check!=null){
						root_node_check = root_node_check.previousSibling();
						drop_position++;
					}
					
					var hidden_category_id = drag.to_nested_form_element("id").writeAttribute('value', drag.id());
					var hidden_parent_id = drag.to_nested_form_element("parent_id").writeAttribute('value', (drag.parent.id()=='null' ? "" : drag.parent.id()) );
					var hidden_position = drag.to_nested_form_element("position").writeAttribute('value', drop_position );
					
					// If elements with match ids are on the page, toss em
					if ($(hidden_parent_id.id)) $(hidden_parent_id.id).remove();
					if ($(hidden_position.id)) $(hidden_position.id).remove();
					
					$('account_categories_edit_form').insert(hidden_category_id);
					$('account_categories_edit_form').insert(hidden_parent_id);
					$('account_categories_edit_form').insert(hidden_position);
					
	    			}
	  	});
		categories_tree.setSortable();
		$('categories_list').select('input[type=\'checkbox\']').each( function (inp){ inp.setStyle({opacity:0.6}); inp.disable(); });
		categories_editing = true;
	}
}

var create_category_name_nmfe = function(category_id, name_element) {
	var id_el_name = 'account[categories_attributes][' + category_id + '][id]';
	var name_el_name = 'account[categories_attributes][' + category_id + '][name]';
 	var hidden_name_element = Builder.node('input', {'type': 'hidden', name: name_el_name, id: name_el_name.replace(/\]\[|\[|\]/g, "_").replace(/_$/, "" )}).writeAttribute('value', $F(name_element));
	var hidden_id_element = Builder.node('input', {'type': 'hidden', name: id_el_name, id: id_el_name.replace(/\]\[|\[|\]/g, "_").replace(/_$/, "" )}).writeAttribute('value', category_id);
 	
	$('account_categories_edit_form').insert(hidden_id_element);
	$('account_categories_edit_form').insert(hidden_name_element);
}


//Toolbox - base class for a toolbox.

var Toolbox = Class.create({
	initialize: function( element ) {
		this.element = $(element);
		this.visible = true;
		this.element.down().next().down().toolbox = this;
		
	    Event.observe(this.element.down().next().down(), 'click', this.onclick.bindAsEventListener(this));
		
	},
	
	hide: function() {
		this.element.down().next().down(1).writeAttribute('style', 'background-position: 0px 2px;');
		new Effect.BlindUp(this.element.down().next(2), {duration: 0.2});
		this.element.down().next(3).hide();
		this.visible = false;		
	},
	
	show: function() {
		this.element.down().next().down(1).writeAttribute('style', 'background-position: 0px -31px;');
		this.element.down().next(3).show();
		new Effect.BlindDown(this.element.down().next(2), {duration: 0.2});
		this.visible = true;
		
	},
	
	toggle: function(){
		if (this.visible) {
			this.hide();
		} else {
			this.show();
		}
	},
	
	onclick: function(event){
		if(this.detect(event)) this.toggle();
	},
	
	detect: function(e) {
        //find the event object
        var eventTarget = e.target ? e.target: e.srcElement;
        var toolbox = eventTarget.toolbox;
        var candidate = eventTarget;
        while (toolbox == null && candidate.parentNode) {
            candidate = candidate.parentNode;
            toolbox = candidate.toolbox;
        }
        return toolbox != null && toolbox.element == this.element;

    },
});

/* Resizing text area class */

var ResizingTextArea = Class.create();

ResizingTextArea.prototype = {
    defaultRows: 1,

    initialize: function(field)
    {
        this.defaultRows = Math.max(field.rows, 1);
        this.resizeNeeded = this.resizeNeeded.bindAsEventListener(this);
        Event.observe(field, "click", this.resizeNeeded);
        Event.observe(field, "keyup", this.resizeNeeded);
    },

    resizeNeeded: function(event)
    {
        var t = Event.element(event);
        var lines = t.value.split('\n');
        var newRows = lines.length + 1;
        var oldRows = t.rows;
        for (var i = 0; i < lines.length; i++)
        {
            var line = lines[i];
            if (line.length >= t.cols) newRows += Math.floor(line.length / t.cols);
        }
        if (newRows > t.rows) t.rows = newRows;
        if (newRows < t.rows) t.rows = Math.max(this.defaultRows, newRows);
    }
}
