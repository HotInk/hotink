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


//Toolbox - base class for a toolbox.

var Toolbox = Class.create({
	initialize: function( element ) {
		this.element = $(element);
		this.visible = true;
		this.element.down().next().down().toolbox = this;
		
	    Event.observe(this.element.down().next().down(), 'click', this.onclick.bindAsEventListener(this));
		
	},
	
	hide: function() {
		this.element.down().next().down(1).writeAttribute('style', 'background-position: 0px 3px;');
		new Effect.BlindUp(this.element.down().next(2), {duration: 0.2});
		this.element.down().next(3).hide();
		this.visible = false;		
	},
	
	show: function() {
		this.element.down().next().down(1).writeAttribute('style', 'background-position: 0px -29px;');
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

toolbox_render = function(title, content) {
			var element =	Builder.node('div',{class:'toolbox'},[
								Builder.node('div', {className: 'toolbox_border'}),
								Builder.node('div', {className: 'toolbox_label_body'},[
									Builder.node('h2',[ 
										Builder.node('span', '    '),
										title
									])
								]),
								Builder.node('div', {className: 'toolbox_border'}),
								Builder.node('div', {className: 'toolbox_body'},
									content
								),
								Builder.node('div', {className: 'toolbox_border'})												
						]);
			return element;
};