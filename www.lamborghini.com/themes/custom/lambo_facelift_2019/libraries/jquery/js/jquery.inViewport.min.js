/*!
 * jquery-inViewport
 * 1.0.0
 * license: MIT
*/

!function(t,e){if("function"==typeof define&&define.amd)define(["exports"],e);else if("undefined"!=typeof exports)e(exports);else{var o={exports:{}};e(o.exports),t.jqueryInViewport=o.exports}}(this,function(t){"use strict";$.fn.inViewport=function(){var t=$(window),e={top:t.scrollTop(),left:t.scrollLeft()};e.right=e.left+t.width(),e.bottom=e.top+t.height();var o=this.offset();return o.right=o.left+this.outerWidth(),o.bottom=o.top+this.outerHeight(),!(e.right<o.left||e.left>o.right||e.bottom<o.top||e.top>o.bottom)}});