/* **Autocompleter.LocalTokenizer** builds an autocompleter around a text input.

The autocompleter searches a supplied json object array for potential matches.

As currently written, the autocompleter handles the necessary hidden form field
creation for a nested model form to add and remove tokens related ONLY by a 
has_many :through relationship. 

There are three classes: the autocompleter class, a token class, and a hidden 
input class that captures keyboard input while tokens are selected.

Dependencies: prototype.js, controls.js, effects.js, builder.js

Last saved: Feb 22, 2009
Future development: 
	- Support tokens related by has_many relationship

*/
Autocompleter.LocalTokenizer = Class.create(Autocompleter.Base, {
    initialize: function(element, update, array, options) {
        this.baseInitialize(element, update, options);
        this.options.array = array;
        this.wrapper = $(this.element.parentNode);
		this.tokens = [],
		
		//Load hidden input
		this.hidden_input = new HiddenInput(this.options.hidden_input_id, this);

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
		
		this.addSavedTokensToList(this.options.saved_token_join_json)	    
	    Event.observe(this.element, 'keypress', this.onKeyUp.bindAsEventListener(this));
	   
    },
getUpdatedChoices: function() {
        this.updateChoices(this.options.selector(this));

    },
onKeyUp: function(event) {
		
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
updateElement: function(selectedElement) {
	if (this.options.updateElement) {
      this.options.updateElement(selectedElement);
      return;
    }
	this.addTokenToList(selectedElement);
},
onNewToken: function( new_token_text ){
	if (this.options.onNewToken) this.options.onNewToken(new_token_text, this);
},
set_input_size: function( load_small ) {
	if( load_small ) {
		this.element.setStyle({width: "20px"});
	} else {
		if (this.element.value == '') {
			var token_width = 0;
			for (var i = 0; i<this.tokens.length;i++) {
				var new_width = token_width + this.tokens[i].element.getWidth();
				if (new_width > this.options.text_field_width) token_width = 0;
				token_width = token_width + this.tokens[i].element.getWidth();
			}
			this.element.setStyle({width: (this.options.text_field_width - token_width - 20) + "px"});
			return true;
		} else {
			var field_width = 20;
			if (this.element.value!='undefined') field_width = field_width + (this.element.value.length * 7);
			this.element.setStyle({width: field_width + "px"});
			return true;
		}
	}		
},
onKeyPress: function(event) {
		console.log(event);
        //dynamically resize the input field
		this.set_input_size();

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
                new_token_text  = this.element.value.strip();				
                if (new_token_text  && new_token_text !="") {
					new_token_text = new_token_text.split(this.options.token_delimiter)
					if (new_token_text instanceof Array) {
						for (var b = 0;b<new_token_text.length;b++){
							this.onNewToken( new_token_text[b].strip() );
						}
					} else {
                    this.onNewToken( new_token_text );
					}
                    Event.stop(event);
                } 
                this.element.value = "";
                return false;

            }
            switch (event.keyCode) {
                //jump left to token
                case Event.KEY_LEFT:
            case Event.KEY_BACKSPACE:
                if (this.element.value == "" && typeof this.wrapper.previous().token != "undefined") {
                    this.wrapper.previous().token.select();
                }
				this.set_input_size ( true );
                return;
                //jump right to token
                case Event.KEY_RIGHT:
                if (this.element.value == "" && this.wrapper.next() && typeof this.wrapper.next().token != "undefined") {
                    this.wrapper.next().token.select();
					this.set_input_size ( true );
                }

            }

        }

        this.changed = true;
        this.hasFocus = true;

        if (this.observer) clearTimeout(this.observer);
        this.observer = 
        setTimeout(this.onObserverEvent.bind(this), this.options.frequency * 1000);

    },
addTokenToList: function(item, value) {
			if (item instanceof Element) {
				var value = Element.readAttribute(item,'value')
			} 	
			this.element.value = ""; 
		    var token = Builder.node('a', {
		        "class": 'token',
				"onclick": "return false;",
		        href: "#",
		        tabindex: "-1"
		    },
		    Builder.node('span', 
		    Builder.node('span', 
		    Builder.node('span', 
		    Builder.node('span', {},
		    [Builder.node('input', { type: "hidden", id: this.options.parent_model + "_" + this.options.search_join_models + "_attributes_new_" + this.options.new_token_count + "_" + this.options.search_model + "_id", 
				name: this.options.parent_model + "[" + this.options.search_join_models + "_attributes][new_" + this.options.new_token_count + "][" + this.options.search_model + "_id]",
		        value: this.options.array[value][this.options.search_model].id
		    }), 
			this.options.array[value][this.options.search_model][this.options.search_field],
		        Builder.node('span',{"class":'x',onmouseout:"this.className='x'",onmouseover:"this.className='x_hover'",
		        onclick:"this.parentNode.parentNode.parentNode.parentNode.parentNode.remove(true); return false;"}," ")
		        ]
		    )
		    )
		    )   
		    )
			); 
			$(token).down(4).next().innerHTML = "&nbsp;";
		 	this.tokens.push(new Token(token,this.hidden_input,false));
			this.options.new_token_count = this.options.new_token_count + 1;
			console.log("New token");
		    this.wrapper.insert({before:token});
},
addSavedTokensToList: function(saved_tokens_join_json) {
	    	tokens = eval(saved_tokens_join_json);
			for (var i = 0; i < tokens.length; i++) {
				var delete_tag_id = this.options.parent_model + "_" + this.options.search_join_models+ "_attributes_" + tokens[i][this.options.search_join_model].id + "__delete";
				var delete_tag_name = this.options.parent_model + "[" + this.options.search_join_models + "_attributes][" + tokens[i][this.options.search_join_model].id + "][_delete]";
				var new_token = Builder.node('a', {
			        "class": 'token',
					"onclick": "return false;",
			        href: "#",
			        tabindex: "-1"
			    },
			    Builder.node('span', 
			    Builder.node('span', 
			    Builder.node('span', 
			    Builder.node('span', {},
			    [ tokens[i].authorship[this.options.search_model][this.options.search_field],
			        Builder.node('span',{"class":'x',onmouseout:"this.className='x'",onmouseover:"this.className='x_hover'",
			        onclick:"this.parentNode.parentNode.parentNode.parentNode.parentNode.remove(true);$('" + delete_tag_id + "').value=1; return false;"}," ")
			        ]
			    )
			    )
			    )   
			    )
				); 
				$(new_token).down(4).innerHTML = "&nbsp;";
			 	new_token = new Token(new_token,this.hidden_input,true);
				this.tokens.push(new_token);
				new_token.delete_tag = new Element('input', {'type':'hidden', 'name': delete_tag_name, 'id': delete_tag_id});
				this.wrapper.insert({before:new_token.element});
				this.update.insert({after:new_token.delete_tag});
			} 
	},		
setOptions: function(options) {
        this.options = Object.extend({
            choices: 10,
            partialSearch: true,
            partialChars: 2,
            ignoreCase: true,
            fullSearch: false,
			new_token_count: 1,
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
}); //End of Class Autocompleter.LocalTokenizer

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
                });
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
				
				//Before removing the element, mark its nested model delete tag, if necessary
				if(this.token.saved) this.token.mark_for_delete();
                
				this.token.element.remove();
                this.auto_complete.element.focus();
                return false;
            }
        }
    }


});

Token = Class.create({
    initialize: function(element, hidden_input, saved) {
        this.element = $(element);
        this.hidden_input = hidden_input;
		this.saved = saved;
        this.element.token = this;
        this.selected = false;
        Event.observe(document, 'click', this.onclick.bindAsEventListener(this));

    },
    select: function() {
		//Deselect the current token, if necessary
		if (this.hidden_input.token != undefined) this.hidden_input.token.deselect();
		
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
        } else if(this.detect(event)) {
            this.deselect();

        }
    },
	mark_for_delete: function() {
		this.delete_tag.value = 1;
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