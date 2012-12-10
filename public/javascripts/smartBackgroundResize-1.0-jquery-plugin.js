/*

* The MIT License (MIT)
* Copyright (c) 2012 
* PHP NINJA Programacion a medida
* www.phpninja.info
*
* Smart Background Resize 
* v.1.1 june 2012
* jQuery Plugin
* contacto@phpninja.info 
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without 
* restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*		
*
*/
(function($){
    $.smartBackgroundResize = function(el, options, options){
          
        var base = this;
        var isIE = false;
       	isIE = $.browser.msie;
        base.$el = $(el);
        base.el = el;
        base.$el.data(el, base);        // Add a reverse reference to the DOM object
		var images,imagePath, imageActual,preloadActual,picWidth,picHeight, isVideo;
		            
        base.init = function(){    
            base.options = $.extend({},$.smartBackgroundResize.defaultOptions, options);            
            base.$el.css("display", "none");
            base.$el.css("line-height","0px");
	        base.$el.css("position","fixed");
	        base.$el.css("z-index","-100");
	        base.$el.css("overflow","hidden");
	        base.$el.css("margin","0px");
	 	    base.$el.css("padding","0px");
        	base.image = base.options.image;
			base.$el.html('<img id="main_image" style="position:absolute;" src="'+base.getImageSourceActual()+'">"');        	
        	base.mainimage = $('#main_image');
            base.loadFirstimage();
            
            $(window).bind('resize', function() {base.resizeImage();	});
        };
              
  		
 
  	base.resizeImage = function() {	

		var navWidth = $(window).width();
		var navHeight = $(window).height();
		var navRatio = navWidth / navHeight;
	
		if (base.mainimage.width() > 1) picWidth = base.mainimage.width();
		if (base.mainimage.height() > 1) picHeight = base.mainimage.height();
		picRatio = picWidth / picHeight;	
		if (navRatio > picRatio) {
			var newHeight = (navWidth / picWidth) * picHeight;
			var newWidth = navWidth;
		} else {
			var newHeight = navHeight;
			var newWidth = (navHeight / picHeight) * picWidth;
		}
		
		newTop = 0 - ((newHeight - navHeight) / 2);
		newLeft =  0 - ((newWidth - navWidth) / 2);

		base.$el.css({height: navHeight, width: navWidth});
		base.$el.css({visibility:"visible", display:"block"});
		base.mainimage.css({height: newHeight, width: newWidth});	
		base.mainimage.css("top",newTop+"px");
		base.mainimage.css("left",newLeft+"px");

	};


	
	base.preloadImage = function(source, nextEvent) {
	    $('<img />').attr('src', source).load(nextEvent);		    
	};
	
	base.loadFirstimage = function() {
		var imageSource = base.getImageSourceActual();
		base.preloadImage(imageSource, base.loadFirstimageEnd);
	};
	
	base.loadFirstimageEnd=function () {
		var imageSource = base.getImageSourceActual();	
		base.mainimage.attr("src",imageSource);
		base.$el.fadeIn(1000);
		base.resizeImage();
	};
	
	
	base.getImageSourceActual=function (){
	
		var idImage = base.image;
		var imageSource = base.options.imagePath+idImage;
		
		return imageSource;
	};
	
     base.init();
 };
    
    $.smartBackgroundResize.defaultOptions = {
    		imagePath: "",
			imageActual: 0,
			preloadActual: 0		
  	};    
    $.fn.smartBackgroundResize = function(options){
		$('body').css("margin","0px");
		$('body').css("padding","0px");
        return this.each(function(){
            (new $.smartBackgroundResize(this, options, options));
        });
    };
    
})(jQuery);