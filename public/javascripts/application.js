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
// This is 100% custom functionality. It would probably be worthwhile to abstract it, though.

var categories_editing = false;
var categories_tree = {};
var load_category_edit = function(){
	
	if (categories_editing) {
		categories_tree.setUnsortable();
		$('account_article_sorting_list').select('ul').each( function(cl){ cl.setStyle({cursor: 'default'}) });
		new Effect.SlideUp($('hidden_categories_buttons'), {duration:0.1});
		$('categories_list').select('input').each( function (inp){ inp.setStyle({opacity:1.0}); inp.enable(); });
		categories_editing = false;
	} else {
		$('account_article_sorting_list').select('ul').each( function(cl){ cl.setStyle({cursor: 'move'}) });
		new Effect.SlideDown($('hidden_categories_buttons'), {duration:0.1});
		categories_tree = new SortableTree('categories_sort', {
			onDrop: function(drag, drop, event){
	      			$('account_categories_order').value = ($('account_categories_order').value + "&" + drag.to_params());
	    			}
	  	});
		categories_tree.setSortable();
		$('categories_list').select('input').each( function (inp){ inp.setStyle({opacity:0.0}); inp.disable(); });
		categories_editing = true;
	}
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
