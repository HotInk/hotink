/* Overlay - overlay.js

Creates a class for an element that inserts itself over the page.

*/

var Overlay = { };

Overlay = Class.create({
	initialize: function( options ) {
		this.fileLoadingImage = '/loading.gif';
		this.overlayOpacity = 0.8;
		this.borderSize = 0;		//if you adjust the padding in the CSS, you will need to update this variable
		this.animate = true;
		this.resizeSpeed = 9;        // controls the speed of the image resizing animations (1=slowest and 10=fastest)
		this.started = false;
		if (options && options['duration']){
			this.duration = options['duration'];
		} else {
			this.duration = 0.1;  	// shadow fade in/out duration
		}
		this.resizeDuration = this.animate ? ((11 - this.resizeSpeed) * 0.15) : 0;
		var size = (this.animate ? 250 : 1) + 'px';
				
		// Code below inserts html at the bottom of the page that looks similar to this:
        //
        //  <div id="overlay"></div>
        //  <div id="overlaybox">
        // 	    <div id="overlaybox_container">
        //          <div id="overlay_content">
		//			</div>
        //      	<div id="loading">
        //          	<a href="#" id="loadingLink">
        //              	<img src="images/loading.gif">
        //              </a>
        //          </div>
		//		</div>
        //  </div>      
		var objBody = $$('body')[0];

		objBody.appendChild(Builder.node('div',{id:'overlay'}));
		
		objBody.appendChild(Builder.node('div',{id:'overlaybox'}, [
            Builder.node('div',{id:'overlay_container'}, [ Builder.node('div',{id:'overlay_content'}), Builder.node('div',{id:'loading'}, 
                   Builder.node('a',{id:'loading_link', href: '#' }, 
                       Builder.node('img', {src: this.fileLoadingImage})
                   )
                )
            ]),
        ]));
		
		$('overlay').hide().observe('click', (function() { this.end(); }).bind(this));
		$('overlaybox').hide().observe('click', (function(event) { if (event.element().id == 'overlaybox') this.end(); }).bind(this));
		
		 var th = this;
	     (function() {	var ids = 'overlay overlaybox overlay_container overlay_content loading loading_link';   
	            		$w(ids).each(function(id){ th[id] = $(id); });
	        		 }).defer();
	},
	
	start: function() {
		if(this.started) return true;
		
		// TODO: Fix this section to hide only elements necessary by browser (ie, textareas in Firefox 2 but not 3)
		$$('select', 'object', 'embed').each(function(node){ node.style.visibility = 'hidden' });
		$$('textarea').each(function(node){ node.style.overflow = 'hidden' });
		
	    var arrayPageSize = this.getPageSize();
		$('overlay').setStyle({ width: arrayPageSize[0] + 'px', height: arrayPageSize[1] + 'px' });		
		
		new Effect.Appear(this.overlay, { duration: 0.2, from: 0.0, to: 0.8 });

		// calculate top and left offset for the overlaybox 
	    var arrayPageScroll = document.viewport.getScrollOffsets();
		var overlayboxTop = arrayPageScroll[1] + (document.viewport.getHeight() / 10);
	    var overlayboxLeft = arrayPageScroll[0];
	    this.overlaybox.setStyle({ top: overlayboxTop + 'px', left: overlayboxLeft + 'px' }).show();
		
		//Hide elements during loading
		if (this.animate) this.loading.show();
		this.overlay_content.hide();
		
	    return true;
	},
	
	render: function( new_content ){
		if (this.start()){
			this.overlay_content.innerHTML = "";
			this.overlay_content.insert( new_content );
			this.overlay_content.hide();
			
			//Preload image and return the last one.
			var image = this.preloadImages()
			//If there are images, attach the animation to the loading of the last image.
			//If there are no images, animate away.
			if (image) {
				if(Prototype.Browser.Opera){
						var dimensions = this.overlay_content.getDimensions();
						//showContent() is called at the end of resizeContainer()
						this.resizeContainer(dimensions.width, dimensions.height);
				} else {
					image.onload = (function(){
						var dimensions = this.overlay_content.getDimensions();
						//showContent() is called at the end of resizeContainer()
						this.resizeContainer(dimensions.width, dimensions.height);
			        }).bind(this);
				}
			} else {
				var dimensions = this.overlay_content.getDimensions();
				//showContent() is called at the end of resizeContainer()
				this.resizeContainer(dimensions.width, dimensions.height);
			}
				
			return true;
		} else {
			return false;
		}
    },

	showContent: function() {
		this.loading.hide();			
		new Effect.Appear(this.overlay_content, { 
            duration: this.resizeDuration, 
            queue: 'end' 
        });
	},
	
	end: function() {
        //this.disableKeyboardNav();
        this.overlaybox.hide();
        new Effect.Fade(this.overlay, { duration: this.duration });
        $$('select', 'object', 'embed').each(function(node){ node.style.visibility = 'visible' });
		$$('textarea').each(function(node){ node.style.overflow = 'auto' });
		
		this.started = false;
    },

	toggle: function() {
		if (this.started) {
			this.end();
		} else {
			this.start();
		}
	},
	
	preloadImages: function(){
		var preloadImages = this.overlay_content.select('img');
		var last_image = {};
		if (preloadImages.length>0){
			for (i=0;i<preloadImages.length;i++) {
				last_image = new Image();
				last_image.src = preloadImages[i].readAttribute('src');
			}
			return last_image;
		} else {
			return false;
		}
	},
	
	//
    //  getPageSize() and resizeContainer() (as resizeImageContainer()) - Poached from Lightbox v2.04
	//	by Lokesh Dhakar - http://www.lokeshdhakar.com
	//	Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
    //  
	//
    // 
    //
    resizeContainer: function(contentWidth, contentHeight) {
        // get current width and height
        var dimensions = this.overlay_container.getDimensions();
        var widthCurrent  = dimensions.width;
        var heightCurrent = dimensions.height;

        // get new width and height
        var widthNew  = (contentWidth  + this.borderSize * 2);
        var heightNew = (contentHeight + this.borderSize * 2);

        // scalars based on change from old to new
        var xScale = (widthNew  / widthCurrent)  * 100;
        var yScale = (heightNew / heightCurrent) * 100;

        // calculate size difference between new and old image, and resize if necessary
        var wDiff = widthCurrent - widthNew;
        var hDiff = heightCurrent - heightNew;

        if (hDiff != 0) new Effect.Scale(this.overlay_container, yScale, {scaleX: false, duration: this.resizeDuration, queue: 'front'}); 
        if (wDiff != 0) new Effect.Scale(this.overlay_container, xScale, {scaleY: false, duration: this.resizeDuration, delay: this.resizeDuration}); 

        // if new and old content are same size and no scaling transition is necessary, 
        // do a quick pause to prevent flicker.
        var timeout = 0;
        if ((hDiff == 0) && (wDiff == 0)){
            timeout = 100;
            if (Prototype.Browser.IE) timeout = 250;   
        }

		(function(){
            this.showContent();
			this.started = true;
        }).bind(this).delay(timeout / 1000);	
    },
    
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
