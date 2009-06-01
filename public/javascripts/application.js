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
	if(Prototype.Browser.Gecko) $$('button').each(function(bt){bt.setStyle({marginLeft: "-3px", marginRight: "-3px"});});
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

// Fade flash function hides flash notices shortly after they're loaded.
 var fade_flash = function() {
	$('flash').down().fade();
}

var trigger_flash = function ( message ) {
	$('flash').innerHTML = ( message );
	fade_flash.delay(1);
}

// Category edit functionality

function edit_category( category_li ){
	li = $(category_li);
	li.down().fade({queue: 'front', duration: 0.1});
	show_category_form.delay(0.4, li);
}
function show_category_form( category_li ) {
	li = $(category_li);
	li.down().next().setStyle({visibility:'visible'});	
}

var i_am_reordering_categories = false;
var categories_tree = {};
var toggle_category_reordering = function(){
	
	if (i_am_reordering_categories) {
		// Then end the reordering session
		$('categories').select('li div.category div.edit, li div.category div.kill_link').invoke('show');
		$('categories_reorder_submit').setStyle({visibility:"hidden"});$('categories_reorder_toggle').setStyle({visibility:"visible"});
		categories_tree.setUnsortable();
		$('categories_order_form').select('.spinner')[0].hide();
		i_am_reordering_categories = false;
	} else {
		// Begin a reordering session
		$('categories').select('li div.category div.edit, li div.category div.kill_link').invoke('hide');
		$('categories_reorder_toggle').setStyle({visibility:"hidden"});$('categories_reorder_submit').setStyle({visibility:"visible"});
		
		// Make sure the categories are showing and category forms are hidden
		$('categories').select('li').each( 
				function (list_item){ 
					if( !list_item.down().visible() ) { 
						list_item.down().next().setStyle({visibility:'hidden'});
						list_item.down().show(); 
					}
				}
	 	);
			
		categories_tree = new SortableTree('categories', {
			onDrop: function(drag, drop, event){
				
				// Find and set the dragged category's new parent id 
				var parent = {};
				if ( drag.element.up()==$('categories') ) { 
					parent = drag.element.up();
					$(drag.element.id +"_parent_id").value="";
				} else {
					parent = drag.element.up()
					var parent_id = parent.up().id.split("_")[1] // Move up from the "parent" list to get the "parent" <li>'s id
					$(drag.element.id +"_parent_id").value=parent_id;
				}
				
				// Find and set the position for each of that parent's children
				var child = parent.down();
				var child_position = 1;
				while( child ) {
					$(child.id + '_position').value = child_position;
					child=child.next(); child_position++;
				}
			},
			containerTagName: 'OL'
		});
		categories_tree.setSortable();
		i_am_reordering_categories = true;
	}
}


// Medialist clean-up tool

var media_list_clean_up = function( array_of_ids ){
	for(var i = 0; i < array_of_ids.length; i++){
		if ($('mediafile_' + array_of_ids[i])) $('mediafile_' + array_of_ids[i]).remove();
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

/* Index page "card" functionality */

var Card = Class.create({
	initialize: function(element, selected) {
		this.element = $(element);
		this.document_link = this.element.select('.document_link')[0];
		this.delete_link = this.element.select('.delete_link')[0];
		this.selected = selected;
		this.element.card = this;
		this.checkbox = this.element.select('input[type="checkbox"]')[0];
		Event.observe(this.element, 'click', this.onclick.bindAsEventListener(this));
		Event.observe(this.element, 'mouseover', this.onmouseover.bindAsEventListener(this));	    
		Event.observe(this.element, 'mouseout', this.onmouseout.bindAsEventListener(this));	    
			    
	},
	
	onclick: function( e ) {
		var eventTarget = e.target ? e.target: e.srcElement;
    	skipped_elements = this.element.select('a, img');

		if (!skipped_elements.include(eventTarget)) {
			if (this.selected) {
				this.deselect();
			} else { 
				this.select();
			}
		}
	},
	
	select: function() {
		this.checkbox.checked = true;
		this.element.addClassName("selected_card");
		this.selected = true;
	},
	
	deselect: function() {
		this.checkbox.checked = null;
		this.element.removeClassName("selected_card");
		this.selected = false;
	},
	
	onmouseover: function() {
		this.element.addClassName('highlighted_card');
		this.delete_link.show();
	},
	
	onmouseout: function() {
		this.element.removeClassName('highlighted_card');
		this.delete_link.hide();
	}
});

/* tab window */



var Tab = Class.create({
	initialize: function(element, selected, window_name){
		this.element = $(element);
		this.element.tab = this;
		this.selected = selected;
		this.window_name = window_name==undefined ? this.element.innerHTML.toLowerCase() + '-window' : window_name ;
		this.tab_window = $(this.window_name);
		Event.observe(this.element, 'click', this.onclick.bindAsEventListener(this));
		Event.observe(this.element, 'mouseover', this.onmouseover.bindAsEventListener(this));	    
		Event.observe(this.element, 'mouseout', this.onmouseout.bindAsEventListener(this));		
	},
	
	onmouseover: function() {
		this.element.addClassName('highlighted');
	},
	
	onmouseout: function() {
		this.element.removeClassName('highlighted');
	},
	
	onclick: function() {
		if(!this.selected) this.select();
	},
	
	select: function(){
		if(this.element.up().select('.selected')) this.element.up().select('.selected')[0].tab.deselect();
		this.element.addClassName('selected');
		this.tab_window.show();
		this.selected = true;
	},
	
	deselect: function(){
		this.element.removeClassName('selected');
		this.tab_window.hide();
		this.selected = false;
	},

	toggle: function(){
		if(this.selected) {
			this.deselect();
		} else {
			this.select();
		}
	}
});