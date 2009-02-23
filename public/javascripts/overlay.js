/* Overlay - overlay.js

Creates a class for an element that inserts itself over the page.

*/

var Overlay = { };

Overlay = Class.create({
	initialize: function( options ) {
		fileLoadingImage = 'images/loading.gif';
		this.overlayOpacity = 0.8;
		borderSize = 10;
		this.started = false;
		if (options && options['duration']){
			this.duration = options['duration'];
		} else {
			this.duration = 0.2;  // shadow fade in/out duration
		}
				
		// Code below inserts html at the bottom of the page that looks similar to this:
        //
        //  <div id="overlay"></div>
        //  <div id="overlaybox">
        //      
        //  </div>      
		var objBody = $$('body')[0];

		objBody.appendChild(Builder.node('div',{id:'overlay'}));
	   	objBody.appendChild(Builder.node('div',{id:'overlaybox'}));
		
		$('overlay').hide().observe('click', (function() { this.end(); }).bind(this));
		$('overlaybox').hide().observe('click', (function(event) { if (event.element().id == 'overlaybox') this.end(); }).bind(this));
		
		 var th = this;
	     (function() {	var ids = 'overlay overlaybox';   
	            		$w(ids).each(function(id){ th[id] = $(id); });
	        		 }).defer();
	},
	
	start: function() {
		$$('select', 'object', 'embed').each(function(node){ node.style.visibility = 'hidden' });
        var arrayPageSize = this.getPageSize();
		$('overlay').setStyle({ width: arrayPageSize[0] + 'px', height: arrayPageSize[1] + 'px' });		
		
		new Effect.Appear(this.overlay, { duration: 0.2, from: 0.0, to: 0.8 });
        this.started = true;

		// calculate top and left offset for the overlaybox 
        var arrayPageScroll = document.viewport.getScrollOffsets();
		var overlayboxTop = arrayPageScroll[1] + (document.viewport.getHeight() / 10);
        var overlayboxLeft = arrayPageScroll[0];
        this.overlaybox.setStyle({ top: overlayboxTop + 'px', left: overlayboxLeft + 'px' }).show();
        
	},
	
	end: function() {
        //this.disableKeyboardNav();
        this.overlaybox.hide();
        new Effect.Fade(this.overlay, { duration: this.duration });
        $$('select', 'object', 'embed').each(function(node){ node.style.visibility = 'visible' });
		this.started = false;
    },

	toggle: function() {
		if (this.started) {
			this.end();
		} else {
			this.start();
		}
	},
	
	//
    //  getPageSize() - Poached from Lightbox v2.04
	//	by Lokesh Dhakar - http://www.lokeshdhakar.com
	//	Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
    //
    getPageSize: function() {
	    var xScroll, yScroll;

		if (window.innerHeight && window.scrollMaxY) {	
			xScroll = window.innerWidth + window.scrollMaxX;
			yScroll = window.innerHeight + window.scrollMaxY;
		} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
			xScroll = document.body.scrollWidth;
			yScroll = document.body.scrollHeight;
		} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
			xScroll = document.body.offsetWidth;
			yScroll = document.body.offsetHeight;
		}

		var windowWidth, windowHeight;

		if (self.innerHeight) {	// all except Explorer
			if(document.documentElement.clientWidth){
				windowWidth = document.documentElement.clientWidth; 
			} else {
				windowWidth = self.innerWidth;
			}
			windowHeight = self.innerHeight;
		} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
			windowWidth = document.documentElement.clientWidth;
			windowHeight = document.documentElement.clientHeight;
		} else if (document.body) { // other Explorers
			windowWidth = document.body.clientWidth;
			windowHeight = document.body.clientHeight;
		}	

		// for small pages with total height less then height of the viewport
		if(yScroll < windowHeight){
			pageHeight = windowHeight;
		} else { 
			pageHeight = yScroll;
		}

		// for small pages with total width less then width of the viewport
		if(xScroll < windowWidth){	
			pageWidth = xScroll;		
		} else {
			pageWidth = windowWidth;
		}
		
		return [pageWidth,pageHeight];
	}
	
});

//Toolbox.base - base class for a toolbox.

var Toolbox = Class.create({
	initialize: function( element ) {
		this.element = $(element);
		this.visible = true;
		this.element.down().next().down().toolbox = this;
		
	    Event.observe(this.element.down().next().down(), 'click', this.onclick.bindAsEventListener(this));
		
	},
	
	hide: function() {
		new Effect.BlindUp(this.element.down().next(2), {duration: 0.2});
		this.element.down().next(3).hide();
		this.visible = false;
	},
	
	show: function() {
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

    }
	
});