/*global jQuery */
/*!
* FitText.js 1.1
*
* Copyright 2011, Dave Rupert http://daverupert.com
* Released under the WTFPL license
* http://sam.zoy.org/wtfpl/
*
* Date: Thu May 05 14:23:00 2011 -0600
*/

(function( $ ){
		
  // Remove Target
  var removeTarget = [];

  $.fn.fitText = function( kompressor, options ) {

	// Setup options
	var compressor = kompressor || 1,
		settings = $.extend({
			'minFontSize' : Number.NEGATIVE_INFINITY,
			'maxFontSize' : Number.POSITIVE_INFINITY,
			'lineHeightAdjustment'  : false,
			'lineHeightAdd'			: 0,
			'heightAdjustment'		: false,
			'heightAdd'				: 0,
			'line'					: 1,
			'callback'				: null
		}, options);

	return this.each(function(){

	// Store the object
	var $this = $(this);
	removeTarget.push($this);

	// Resizer() resizes items based on the object width divided by the compressor * 10
	var resizer = function () {
		var size = Math.max(Math.min($this.width() / (compressor*10), parseFloat(settings.maxFontSize)), parseFloat(settings.minFontSize));
		$this.css({
			'font-size': size
		});
		if ( settings.lineHeightAdjustment ) {
			$this.css({
				'line-height': ( size + settings.lineHeightAdd ) + 'px'
			});
		}
		if ( settings.heightAdjustment ) {
			$this.css({
				'height': ( ( size + settings.heightAdd ) * settings.line ) + 'px',
				'max-height': ( ( size + settings.heightAdd ) * settings.line ) + 'px'
			});
		}
		if ( typeof settings.callback == 'function') {
			settings.callback.call($this);
		}
	};

	// Call once to set.
	resizer();

	// Call on resize. Opera debounces their resize by default.
	$(window).on('resize.fittext orientationchange.fittext', resizer);

	});

  };
  
  $.fn.fitTextRemove = function(options) {
	// Setup options
	var settings = $.extend({'callback': null}, options);
	$(window).off('resize.fittext orientationchange.fittext');
	$.each(removeTarget,function(){
		$(this).css({
			'font-size':'',
			'line-height':'',
			'height':''
		});
		if ( typeof settings.callback == 'function') {
			settings.callback.call($(this));
		}
	});
  };

})( jQuery );
