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

//Author_list autocomplete javascript

Autocompleter.LocalAdvanced = Class.create(Autocompleter.Base, {
    initialize: function(element, update, array, options) {
        this.baseInitialize(element, update, options);
        this.options.array = array;
        this.wrapper = $(this.element.parentNode);

	    if (!this.element.hacks) {
	        this.element.should_use_borderless_hack = Prototype.Browser.WebKit;
	        this.element.should_use_shadow_hack = Prototype.Browser.IE || Prototype.Browser.Opera;
	        this.element.hacks = true;
	    }
		if (this.element.should_use_borderless_hack  || this.element.should_use_shadow_hack) { this.wrapper.addClassName('tokenizer_input_borderless'); }
		
		this.options.onShow = function(element,update) {
		 	Position.clone(element.parentNode.parentNode, update, {
		            setHeight: false, 
					setWidth: false,
		            offsetTop: element.parentNode.parentNode.offsetHeight
		     });		
			update.show(); 
			
		}  
		this.options.onHide = function(element, update){ update.hide() };
	    

    },
getUpdatedChoices: function() {
        this.updateChoices(this.options.selector(this));

    },

onBlur: function($super, event) {
        $super();
        //move itself back to the end on blur
        if (this.wrapper.nextSiblings().length > 0) {
            this.wrapper.nextSiblings().last().insert({
                after: this.wrapper
            });

        }

    },
set_input_size: function(size) {
	size = size || 20;
	this.element.setStyle({width: size + "px"});	
},
onKeyPress: function(event) {
        //dynamically resize the input field
		var new_size = 20 + (this.element.value.length * 7);
        if (new_size <= 340) {
			this.set_input_size(new_size);
        } else {
			this.set_input_size(340);
        }
        //active is when there's suggesitons found
        if (this.active)
        switch (event.keyCode) {
        case Event.KEY_TAB:
        case Event.KEY_RETURN:
            this.selectEntry();
            Event.stop(event);
            case Event.KEY_ESC:
            this.hide();
            this.active = false;
            Event.stop(event);
            return;
            case Event.KEY_LEFT:
        case Event.KEY_RIGHT:
            return;
            case Event.KEY_UP:
            this.markPrevious();
            this.render();
            Event.stop(event);
            return;
            case Event.KEY_DOWN:
            this.markNext();
            this.render();
            Event.stop(event);
            return;

        }
        else {
            if (event.keyCode == Event.KEY_TAB || event.keyCode == Event.KEY_RETURN || 
            (Prototype.Browser.WebKit > 0 && event.keyCode == 0) || event.keyCode == 44 /*, comma  */||  event.keyCode == 188 ) {
                new_author = this.element.value.sub(',', '').strip()
                
                if (new_author && new_author!="") {
                    this.options.onNewAuthor( new_author )
                    Event.stop(event);
                } 
                this.element.value = "";
				this.set_input_size();
                return false;

            }
            switch (event.keyCode) {
                //jump left to token
                case Event.KEY_LEFT:
            case Event.KEY_BACKSPACE:
                if (this.element.value == "" && typeof this.wrapper.previous().token != "undefined") {
                    this.wrapper.previous().token.select();

                }
                return;
                //jump right to token
                case Event.KEY_RIGHT:
                if (this.element.value == "" && this.wrapper.next() && typeof this.wrapper.next().token != "undefined") {
                    this.wrapper.next().token.select();

                }

            }

        }

        this.changed = true;
        this.hasFocus = true;

        if (this.observer) clearTimeout(this.observer);
        this.observer = 
        setTimeout(this.onObserverEvent.bind(this), this.options.frequency * 1000);

    },

setOptions: function(options) {
        this.options = Object.extend({
            choices: 10,
            partialSearch: true,
            partialChars: 2,
            ignoreCase: true,
            fullSearch: false,
			tokens: ",",
            selector: function(instance) {
                var ret = [];
                // Beginning matches
                var partial = [];
                // Inside matches
                var entry = instance.getToken();
                var count = 0;

                for (var i = 0; i < instance.options.array.length && 
                ret.length < instance.options.choices; i++) {

                    var elem = instance.options.array[i];
                    var elem_name = elem[instance.options.search_model][instance.options.search_field];
                    var foundPos = instance.options.ignoreCase ? 
                    elem_name.toLowerCase().indexOf(entry.toLowerCase()) : 
                    elem_name.indexOf(entry);

                    while (foundPos != -1) {

                        if (foundPos == 0 && elem_name.length != entry.length) {
                            var value = "<strong>" + elem_name.substr(0, entry.length) + "</strong>" + elem_name.substr(entry.length);
                            ret.push("<li value='" + i + "'>" + "<div>" + value + "</div>" + "</li>");
                            break;

                        } else if (entry.length >= instance.options.partialChars && instance.options.partialSearch && foundPos != -1) {
                            if (instance.options.fullSearch || /\s/.test(elem_name.substr(foundPos - 1, 1))) {
                                var value = elem_name.substr(0, foundPos) + "<strong>" + 
                                elem_name.substr(foundPos, entry.length) + "</strong>" + elem_name.substr(
                                foundPos + entry.length)

                                partial.push("<li value='" + i + "'>" + "<div>" + value + "</div>" + "</li>");
                                break;

                            }

                        }
                        foundPos = instance.options.ignoreCase ? 
                        elem_name.toLowerCase().indexOf(entry.toLowerCase(), foundPos + 1) : 
                        elem_name.indexOf(entry, foundPos + 1);


                    }

                }
                if (partial.length)
                ret = ret.concat(partial.slice(0, instance.options.choices - ret.length));
                return "<ul>" + ret.join('') + "</ul>";

            }

        },
        options || {});

    }

});
HiddenInput = Class.create({
    initialize: function(element, auto_complete) {
        this.element = $(element);
        this.auto_complete = auto_complete;
        this.token;
        Event.observe(this.element, 'keydown', this.onKeyPress.bindAsEventListener(this));

    },
    onKeyPress: function(event) {
        if (this.token.selected) {
            switch (event.keyCode) {
                case Event.KEY_LEFT:
                this.token.element.insert({
                    before:
                    this.auto_complete.wrapper
                })
                this.token.deselect();
                this.auto_complete.element.focus();
                return false;
                case Event.KEY_RIGHT:
                this.token.element.insert({
                    after:
                    this.auto_complete.wrapper
                })
                this.token.deselect();
                this.auto_complete.element.focus();
                return false;
                case Event.KEY_BACKSPACE:
            case Event.KEY_DELETE:
                this.token.element.remove();
                this.auto_complete.element.focus();
                return false;

            }

        }

    }


})
 Token = Class.create({
    initialize: function(element, hidden_input) {
        this.element = $(element);
        this.hidden_input = hidden_input;
        this.element.token = this;
        this.selected = false;
        Event.observe(document, 'click', this.onclick.bindAsEventListener(this));

    },
    select: function() {
        this.hidden_input.token = this;
        this.hidden_input.element.activate();
        this.selected = true;
        this.element.addClassName('token_selected');

    },
    deselect: function() {
        this.hidden_input.token = undefined;
        this.selected = false;
        this.element.removeClassName('token_selected')

    },
    onclick: function(event) {
        if (this.detect(event) && !this.selected) {
            this.select();

        } else {
            this.deselect();

        }

    },
    detect: function(e) {
        //find the event object
        var eventTarget = e.target ? e.target: e.srcElement;
        var token = eventTarget.token;
        var candidate = eventTarget;
        while (token == null && candidate.parentNode) {
            candidate = candidate.parentNode;
            token = candidate.token;

        }
        return token != null && token.element == this.element;

    }

});


addContactToList = function(item) {
   	$('article_new_authors_list').value = "";
    var token = Builder.node('a', {
        "class": 'token',
        href: "#",
        tabindex: "-1"
    },
    Builder.node('span', 
    Builder.node('span', 
    Builder.node('span', 
    Builder.node('span', {},
    [Builder.node('input', { type: "hidden", name: "author_ids[]",
        value: "0"
    }), 
	contacts[Element.readAttribute(item,'value')].author.name,
        Builder.node('span',{"class":'x',onmouseout:"this.className='x'",onmouseover:"this.className='x_hover'",
        onclick:"this.parentNode.parentNode.parentNode.parentNode.parentNode.remove(true); return false;"}," ")
        ]
    )
    )
    )   
    )
	);  
	$(token).down(4).next().innerHTML = "&nbsp;";
 	new Token(token,hidden_input);
   $('autocomplete_display').insert({before:token});
}