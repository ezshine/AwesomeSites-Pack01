(window.webpackJsonp=window.webpackJsonp||[]).push([[4],{665:function(e,t,r){"use strict";r.d(t,"b",(function(){return l})),r.d(t,"a",(function(){return d}));var n=r(1),o=r(2),c=r(0),l=function(){function e(){Object(n.a)(this,e),this.enabled=!0,this.needsSwap=!0,this.clear=!1,this.renderToScreen=!1}return Object(o.a)(e,[{key:"setSize",value:function(){}},{key:"render",value:function(){console.error("THREE.Pass: .render() must be implemented in derived pass.")}}]),e}(),f=new c.OrthographicCamera(-1,1,1,-1,0,1),h=new c.BufferGeometry;h.setAttribute("position",new c.Float32BufferAttribute([-1,3,0,-1,-1,0,3,-1,0],3)),h.setAttribute("uv",new c.Float32BufferAttribute([0,2,0,0,2,0],2));var d=function(){function e(t){Object(n.a)(this,e),this._mesh=new c.Mesh(h,t)}return Object(o.a)(e,[{key:"dispose",value:function(){this._mesh.geometry.dispose()}},{key:"render",value:function(e){e.render(this._mesh,f)}},{key:"material",get:function(){return this._mesh.material},set:function(e){this._mesh.material=e}}]),e}()},667:function(e,t,r){"use strict";r.d(t,"a",(function(){return m}));r(8),r(13);var n=r(1),o=r(2),c=r(4),l=r(7),f=r(3),h=r(0),d=r(665);function v(e){var t=function(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(e){return!1}}();return function(){var r,n=Object(f.a)(e);if(t){var o=Object(f.a)(this).constructor;r=Reflect.construct(n,arguments,o)}else r=n.apply(this,arguments);return Object(l.a)(this,r)}}var m=function(e){Object(c.a)(r,e);var t=v(r);function r(e,o){var c;return Object(n.a)(this,r),(c=t.call(this)).textureID=void 0!==o?o:"tDiffuse",e instanceof h.ShaderMaterial?(c.uniforms=e.uniforms,c.material=e):e&&(c.uniforms=h.UniformsUtils.clone(e.uniforms),c.material=new h.ShaderMaterial({defines:Object.assign({},e.defines),uniforms:c.uniforms,vertexShader:e.vertexShader,fragmentShader:e.fragmentShader})),c.fsQuad=new d.a(c.material),c}return Object(o.a)(r,[{key:"render",value:function(e,t,r){this.uniforms[this.textureID]&&(this.uniforms[this.textureID].value=r.texture),this.fsQuad.material=this.material,this.renderToScreen?(e.setRenderTarget(null),this.fsQuad.render(e)):(e.setRenderTarget(t),this.clear&&e.clear(e.autoClearColor,e.autoClearDepth,e.autoClearStencil),this.fsQuad.render(e))}}]),r}(d.b)},668:function(e,t,r){"use strict";r.d(t,"a",(function(){return n}));var n={uniforms:{tDiffuse:{value:null},opacity:{value:1}},vertexShader:"\n\n\t\tvarying vec2 vUv;\n\n\t\tvoid main() {\n\n\t\t\tvUv = uv;\n\t\t\tgl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n\n\t\t}",fragmentShader:"\n\n\t\tuniform float opacity;\n\n\t\tuniform sampler2D tDiffuse;\n\n\t\tvarying vec2 vUv;\n\n\t\tvoid main() {\n\n\t\t\tvec4 texel = texture2D( tDiffuse, vUv );\n\t\t\tgl_FragColor = opacity * texel;\n\n\t\t}"}},684:function(e,t,r){"use strict";r.d(t,"a",(function(){return x}));r(8),r(13);var n=r(1),o=r(2),c=r(4),l=r(7),f=r(3),h=(r(51),r(0)),d=r(665),v=r(668);function m(e){var t=function(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(e){return!1}}();return function(){var r,n=Object(f.a)(e);if(t){var o=Object(f.a)(this).constructor;r=Reflect.construct(n,arguments,o)}else r=n.apply(this,arguments);return Object(l.a)(this,r)}}var x=function(e){Object(c.a)(r,e);var t=m(r);function r(map,e){var o;Object(n.a)(this,r),o=t.call(this),void 0===v.a&&console.error("THREE.TexturePass relies on CopyShader");var c=v.a;return o.map=map,o.opacity=void 0!==e?e:1,o.uniforms=h.UniformsUtils.clone(c.uniforms),o.material=new h.ShaderMaterial({uniforms:o.uniforms,vertexShader:c.vertexShader,fragmentShader:c.fragmentShader,depthTest:!1,depthWrite:!1}),o.needsSwap=!1,o.fsQuad=new d.a(null),o}return Object(o.a)(r,[{key:"render",value:function(e,t,r){var n=e.autoClear;e.autoClear=!1,this.fsQuad.material=this.material,this.uniforms.opacity.value=this.opacity,this.uniforms.tDiffuse.value=this.map,this.material.transparent=this.opacity<1,e.setRenderTarget(this.renderToScreen?null:r),this.clear&&e.clear(),this.fsQuad.render(e),e.autoClear=n}}]),r}(d.b)},688:function(e,t,r){"use strict";r.d(t,"a",(function(){return w}));var n=r(1),o=r(2),c=(r(22),r(105),r(0)),l=r(668),f=r(667),h=(r(8),r(13),r(4)),d=r(7),v=r(3),m=r(665);function x(e){var t=function(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(e){return!1}}();return function(){var r,n=Object(v.a)(e);if(t){var o=Object(v.a)(this).constructor;r=Reflect.construct(n,arguments,o)}else r=n.apply(this,arguments);return Object(d.a)(this,r)}}var y=function(e){Object(h.a)(r,e);var t=x(r);function r(e,o){var c;return Object(n.a)(this,r),(c=t.call(this)).scene=e,c.camera=o,c.clear=!0,c.needsSwap=!1,c.inverse=!1,c}return Object(o.a)(r,[{key:"render",value:function(e,t,r){var n,o,c=e.getContext(),l=e.state;l.buffers.color.setMask(!1),l.buffers.depth.setMask(!1),l.buffers.color.setLocked(!0),l.buffers.depth.setLocked(!0),this.inverse?(n=0,o=1):(n=1,o=0),l.buffers.stencil.setTest(!0),l.buffers.stencil.setOp(c.REPLACE,c.REPLACE,c.REPLACE),l.buffers.stencil.setFunc(c.ALWAYS,n,4294967295),l.buffers.stencil.setClear(o),l.buffers.stencil.setLocked(!0),e.setRenderTarget(r),this.clear&&e.clear(),e.render(this.scene,this.camera),e.setRenderTarget(t),this.clear&&e.clear(),e.render(this.scene,this.camera),l.buffers.color.setLocked(!1),l.buffers.depth.setLocked(!1),l.buffers.stencil.setLocked(!1),l.buffers.stencil.setFunc(c.EQUAL,1,4294967295),l.buffers.stencil.setOp(c.KEEP,c.KEEP,c.KEEP),l.buffers.stencil.setLocked(!0)}}]),r}(m.b),C=function(e){Object(h.a)(r,e);var t=x(r);function r(){var e;return Object(n.a)(this,r),(e=t.call(this)).needsSwap=!1,e}return Object(o.a)(r,[{key:"render",value:function(e){e.state.buffers.stencil.setLocked(!1),e.state.buffers.stencil.setTest(!1)}}]),r}(m.b),w=function(){function e(t,r){if(Object(n.a)(this,e),this.renderer=t,void 0===r){var o={minFilter:c.LinearFilter,magFilter:c.LinearFilter,format:c.RGBAFormat},h=t.getSize(new c.Vector2);this._pixelRatio=t.getPixelRatio(),this._width=h.width,this._height=h.height,(r=new c.WebGLRenderTarget(this._width*this._pixelRatio,this._height*this._pixelRatio,o)).texture.name="EffectComposer.rt1"}else this._pixelRatio=1,this._width=r.width,this._height=r.height;this.renderTarget1=r,this.renderTarget2=r.clone(),this.renderTarget2.texture.name="EffectComposer.rt2",this.writeBuffer=this.renderTarget1,this.readBuffer=this.renderTarget2,this.renderToScreen=!0,this.passes=[],void 0===l.a&&console.error("THREE.EffectComposer relies on CopyShader"),void 0===f.a&&console.error("THREE.EffectComposer relies on ShaderPass"),this.copyPass=new f.a(l.a),this.clock=new c.Clock}return Object(o.a)(e,[{key:"swapBuffers",value:function(){var e=this.readBuffer;this.readBuffer=this.writeBuffer,this.writeBuffer=e}},{key:"addPass",value:function(e){this.passes.push(e),e.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}},{key:"insertPass",value:function(e,t){this.passes.splice(t,0,e),e.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}},{key:"removePass",value:function(e){var t=this.passes.indexOf(e);-1!==t&&this.passes.splice(t,1)}},{key:"isLastEnabledPass",value:function(e){for(var i=e+1;i<this.passes.length;i++)if(this.passes[i].enabled)return!1;return!0}},{key:"render",value:function(e){void 0===e&&(e=this.clock.getDelta());for(var t=this.renderer.getRenderTarget(),r=!1,i=0,n=this.passes.length;i<n;i++){var o=this.passes[i];if(!1!==o.enabled){if(o.renderToScreen=this.renderToScreen&&this.isLastEnabledPass(i),o.render(this.renderer,this.writeBuffer,this.readBuffer,e,r),o.needsSwap){if(r){var c=this.renderer.getContext(),l=this.renderer.state.buffers.stencil;l.setFunc(c.NOTEQUAL,1,4294967295),this.copyPass.render(this.renderer,this.writeBuffer,this.readBuffer,e),l.setFunc(c.EQUAL,1,4294967295)}this.swapBuffers()}void 0!==y&&(o instanceof y?r=!0:o instanceof C&&(r=!1))}}this.renderer.setRenderTarget(t)}},{key:"reset",value:function(e){if(void 0===e){var t=this.renderer.getSize(new c.Vector2);this._pixelRatio=this.renderer.getPixelRatio(),this._width=t.width,this._height=t.height,(e=this.renderTarget1.clone()).setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}this.renderTarget1.dispose(),this.renderTarget2.dispose(),this.renderTarget1=e,this.renderTarget2=e.clone(),this.writeBuffer=this.renderTarget1,this.readBuffer=this.renderTarget2}},{key:"setSize",value:function(e,t){this._width=e,this._height=t;var r=this._width*this._pixelRatio,n=this._height*this._pixelRatio;this.renderTarget1.setSize(r,n),this.renderTarget2.setSize(r,n);for(var i=0;i<this.passes.length;i++)this.passes[i].setSize(r,n)}},{key:"setPixelRatio",value:function(e){this._pixelRatio=e,this.setSize(this._width,this._height)}}]),e}(),D=(new c.OrthographicCamera(-1,1,1,-1,0,1),new c.BufferGeometry);D.setAttribute("position",new c.Float32BufferAttribute([-1,3,0,-1,-1,0,3,-1,0],3)),D.setAttribute("uv",new c.Float32BufferAttribute([0,2,0,0,2,0],2))},751:function(e,t,r){e.exports=function(){"use strict";var e=function(){var t=0,r=document.createElement("div");function n(e){return r.appendChild(e.dom),e}function o(e){for(var n=0;n<r.children.length;n++)r.children[n].style.display=n===e?"block":"none";t=e}r.style.cssText="position:fixed;top:0;left:0;cursor:pointer;opacity:0.9;z-index:10000",r.addEventListener("click",(function(e){e.preventDefault(),o(++t%r.children.length)}),!1);var i=(performance||Date).now(),a=i,c=0,l=n(new e.Panel("FPS","#0ff","#002")),f=n(new e.Panel("MS","#0f0","#020"));if(self.performance&&self.performance.memory)var h=n(new e.Panel("MB","#f08","#201"));return o(0),{REVISION:16,dom:r,addPanel:n,showPanel:o,begin:function(){i=(performance||Date).now()},end:function(){c++;var e=(performance||Date).now();if(f.update(e-i,200),a+1e3<=e&&(l.update(1e3*c/(e-a),100),a=e,c=0,h)){var t=performance.memory;h.update(t.usedJSHeapSize/1048576,t.jsHeapSizeLimit/1048576)}return e},update:function(){i=this.end()},domElement:r,setMode:o}};return e.Panel=function(e,t,i){var a=1/0,r=0,n=Math.round,o=n(window.devicePixelRatio||1),c=80*o,l=48*o,f=3*o,p=2*o,u=3*o,s=15*o,h=74*o,d=30*o,v=document.createElement("canvas");v.width=c,v.height=l,v.style.cssText="width:80px;height:48px";var m=v.getContext("2d");return m.font="bold "+9*o+"px Helvetica,Arial,sans-serif",m.textBaseline="top",m.fillStyle=i,m.fillRect(0,0,c,l),m.fillStyle=t,m.fillText(e,f,p),m.fillRect(u,s,h,d),m.fillStyle=i,m.globalAlpha=.9,m.fillRect(u,s,h,d),{dom:v,update:function(l,x){a=Math.min(a,l),r=Math.max(r,l),m.fillStyle=i,m.globalAlpha=1,m.fillRect(0,0,c,s),m.fillStyle=t,m.fillText(n(l)+" "+e+" ("+n(a)+"-"+n(r)+")",f,p),m.drawImage(v,u+o,s,h-o,d,u,s,h-o,d),m.fillRect(u+h-o,s,o,d),m.fillStyle=i,m.globalAlpha=.9,m.fillRect(u+h-o,s,o,n((1-l/x)*d))}}},e}()},756:function(e,t,r){"use strict";r.d(t,"a",(function(){return v}));r(8),r(13);var n=r(2),o=r(1),c=r(4),l=r(7),f=r(3),h=function e(){var t=0,r=document.createElement("div");function n(e){return r.appendChild(e.dom),e}function o(e){for(var i=0;i<r.children.length;i++)r.children[i].style.display=i===e?"block":"none";t=e}r.style.cssText="position:fixed;top:0;left:0;cursor:pointer;opacity:0.9;z-index:10000",r.addEventListener("click",(function(e){e.preventDefault(),o(++t%r.children.length)}),!1);var c=(performance||Date).now(),l=c,f=0,h=n(new e.Panel("FPS","#0ff","#002")),d=n(new e.Panel("MS","#0f0","#020"));if(self.performance&&self.performance.memory)var v=n(new e.Panel("MB","#f08","#201"));return o(0),{REVISION:16,dom:r,addPanel:n,showPanel:o,begin:function(){c=(performance||Date).now()},end:function(){f++;var time=(performance||Date).now();if(d.update(time-c,200),time>=l+1e3&&(h.update(1e3*f/(time-l),100),l=time,f=0,v)){var e=performance.memory;v.update(e.usedJSHeapSize/1048576,e.jsHeapSizeLimit/1048576)}return time},update:function(){c=this.end()},domElement:r,setMode:o}};function d(e){var t=function(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(e){return!1}}();return function(){var r,n=Object(f.a)(e);if(t){var o=Object(f.a)(this).constructor;r=Reflect.construct(n,arguments,o)}else r=n.apply(this,arguments);return Object(l.a)(this,r)}}var v=function(e){Object(c.a)(r,e);var t=d(r);function r(e){var n,c=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"GPU MS";Object(o.a)(this,r),n=t.call(this,c,"#f90","#210");var l=!0,f=e.getExtension("EXT_disjoint_timer_query_webgl2");return null===f&&(l=!1,null===(f=e.getExtension("EXT_disjoint_timer_query"))&&console.warn("GPUStatsPanel: disjoint_time_query extension not available.")),n.context=e,n.extension=f,n.maxTime=30,n.activeQueries=0,n.startQuery=function(){var e=this,t=this.context,r=this.extension;if(null!==r){var n;l?(n=t.createQuery(),t.beginQuery(r.TIME_ELAPSED_EXT,n)):(n=r.createQueryEXT(),r.beginQueryEXT(r.TIME_ELAPSED_EXT,n)),this.activeQueries++;requestAnimationFrame((function o(){var c,f,h;l?(c=t.getQueryParameter(n,t.QUERY_RESULT_AVAILABLE),f=t.getParameter(r.GPU_DISJOINT_EXT),h=t.getQueryParameter(n,t.QUERY_RESULT)):(c=r.getQueryObjectEXT(n,r.QUERY_RESULT_AVAILABLE_EXT),f=t.getParameter(r.GPU_DISJOINT_EXT),h=r.getQueryObjectEXT(n,r.QUERY_RESULT_EXT));var d=1e-6*h;c?(f||e.update(d,e.maxTime),e.activeQueries--):requestAnimationFrame(o)}))}},n.endQuery=function(){var e=this.extension,t=this.context;null!==e&&(l?t.endQuery(e.TIME_ELAPSED_EXT):e.endQueryEXT(e.TIME_ELAPSED_EXT))},n}return Object(n.a)(r)}(h.Panel=function(e,t,r){var n=1/0,o=0,c=Math.round,l=c(window.devicePixelRatio||1),f=80*l,h=48*l,d=3*l,v=2*l,m=3*l,x=15*l,y=74*l,C=30*l,canvas=document.createElement("canvas");canvas.width=f,canvas.height=h,canvas.style.cssText="width:80px;height:48px";var w=canvas.getContext("2d");return w.font="bold "+9*l+"px Helvetica,Arial,sans-serif",w.textBaseline="top",w.fillStyle=r,w.fillRect(0,0,f,h),w.fillStyle=t,w.fillText(e,d,v),w.fillRect(m,x,y,C),w.fillStyle=r,w.globalAlpha=.9,w.fillRect(m,x,y,C),{dom:canvas,update:function(h,D){n=Math.min(n,h),o=Math.max(o,h),w.fillStyle=r,w.globalAlpha=1,w.fillRect(0,0,f,x),w.fillStyle=t,w.fillText(c(h)+" "+e+" ("+c(n)+"-"+c(o)+")",d,v),w.drawImage(canvas,m+l,x,y-l,C,m,x,y-l,C),w.fillRect(m+y-l,x,l,C),w.fillStyle=r,w.globalAlpha=.9,w.fillRect(m+y-l,x,l,c((1-h/D)*C))}}})},757:function(e,t,r){"use strict";r.d(t,"a",(function(){return x}));r(8),r(13);var n=r(1),o=r(2),c=r(4),l=r(7),f=r(3),h=(r(22),r(0)),d=r(665),v={defines:{DEPTH_PACKING:1,PERSPECTIVE_CAMERA:1},uniforms:{tColor:{value:null},tDepth:{value:null},focus:{value:1},aspect:{value:1},aperture:{value:.025},maxblur:{value:.01},nearClip:{value:1},farClip:{value:1e3}},vertexShader:"\n\n\t\tvarying vec2 vUv;\n\n\t\tvoid main() {\n\n\t\t\tvUv = uv;\n\t\t\tgl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n\n\t\t}",fragmentShader:"\n\n\t\t#include <common>\n\n\t\tvarying vec2 vUv;\n\n\t\tuniform sampler2D tColor;\n\t\tuniform sampler2D tDepth;\n\n\t\tuniform float maxblur; // max blur amount\n\t\tuniform float aperture; // aperture - bigger values for shallower depth of field\n\n\t\tuniform float nearClip;\n\t\tuniform float farClip;\n\n\t\tuniform float focus;\n\t\tuniform float aspect;\n\n\t\t#include <packing>\n\n\t\tfloat getDepth( const in vec2 screenPosition ) {\n\t\t\t#if DEPTH_PACKING == 1\n\t\t\treturn unpackRGBAToDepth( texture2D( tDepth, screenPosition ) );\n\t\t\t#else\n\t\t\treturn texture2D( tDepth, screenPosition ).x;\n\t\t\t#endif\n\t\t}\n\n\t\tfloat getViewZ( const in float depth ) {\n\t\t\t#if PERSPECTIVE_CAMERA == 1\n\t\t\treturn perspectiveDepthToViewZ( depth, nearClip, farClip );\n\t\t\t#else\n\t\t\treturn orthographicDepthToViewZ( depth, nearClip, farClip );\n\t\t\t#endif\n\t\t}\n\n\n\t\tvoid main() {\n\n\t\t\tvec2 aspectcorrect = vec2( 1.0, aspect );\n\n\t\t\tfloat viewZ = getViewZ( getDepth( vUv ) );\n\n\t\t\tfloat factor = ( focus + viewZ ); // viewZ is <= 0, so this is a difference equation\n\n\t\t\tvec2 dofblur = vec2 ( clamp( factor * aperture, -maxblur, maxblur ) );\n\n\t\t\tvec2 dofblur9 = dofblur * 0.9;\n\t\t\tvec2 dofblur7 = dofblur * 0.7;\n\t\t\tvec2 dofblur4 = dofblur * 0.4;\n\n\t\t\tvec4 col = vec4( 0.0 );\n\n\t\t\tcol += texture2D( tColor, vUv.xy );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.15,  0.37 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.37,  0.15 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.40,  0.0  ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.37, -0.15 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.15, -0.37 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.15,  0.37 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.37,  0.15 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.37, -0.15 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.15, -0.37 ) * aspectcorrect ) * dofblur );\n\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.15,  0.37 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.37,  0.15 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.37, -0.15 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.15, -0.37 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.15,  0.37 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.37,  0.15 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.37, -0.15 ) * aspectcorrect ) * dofblur9 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.15, -0.37 ) * aspectcorrect ) * dofblur9 );\n\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.40,  0.0  ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur7 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur7 );\n\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.4,   0.0  ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur4 );\n\t\t\tcol += texture2D( tColor, vUv.xy + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur4 );\n\n\t\t\tgl_FragColor = col / 41.0;\n\t\t\tgl_FragColor.a = 1.0;\n\n\t\t}"};function m(e){var t=function(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(e){return!1}}();return function(){var r,n=Object(f.a)(e);if(t){var o=Object(f.a)(this).constructor;r=Reflect.construct(n,arguments,o)}else r=n.apply(this,arguments);return Object(l.a)(this,r)}}var x=function(e){Object(c.a)(r,e);var t=m(r);function r(e,o,c){var l;Object(n.a)(this,r),(l=t.call(this)).scene=e,l.camera=o;var f=void 0!==c.focus?c.focus:1,m=void 0!==c.aspect?c.aspect:o.aspect,x=void 0!==c.aperture?c.aperture:.025,y=void 0!==c.maxblur?c.maxblur:1,C=c.width||window.innerWidth||1,w=c.height||window.innerHeight||1;l.renderTargetDepth=new h.WebGLRenderTarget(C,w,{minFilter:h.NearestFilter,magFilter:h.NearestFilter}),l.renderTargetDepth.texture.name="BokehPass.depth",l.materialDepth=new h.MeshDepthMaterial,l.materialDepth.depthPacking=h.RGBADepthPacking,l.materialDepth.blending=h.NoBlending,void 0===v&&console.error("THREE.BokehPass relies on BokehShader");var D=v,R=h.UniformsUtils.clone(D.uniforms);return R.tDepth.value=l.renderTargetDepth.texture,R.focus.value=f,R.aspect.value=m,R.aperture.value=x,R.maxblur.value=y,R.nearClip.value=o.near,R.farClip.value=o.far,l.materialBokeh=new h.ShaderMaterial({defines:Object.assign({},D.defines),uniforms:R,vertexShader:D.vertexShader,fragmentShader:D.fragmentShader}),l.uniforms=R,l.needsSwap=!1,l.fsQuad=new d.a(l.materialBokeh),l._oldClearColor=new h.Color,l}return Object(o.a)(r,[{key:"render",value:function(e,t,r){this.scene.overrideMaterial=this.materialDepth,e.getClearColor(this._oldClearColor);var n=e.getClearAlpha(),o=e.autoClear;e.autoClear=!1,e.setClearColor(16777215),e.setClearAlpha(1),e.setRenderTarget(this.renderTargetDepth),e.clear(),e.render(this.scene,this.camera),this.uniforms.tColor.value=r.texture,this.uniforms.nearClip.value=this.camera.near,this.uniforms.farClip.value=this.camera.far,this.renderToScreen?(e.setRenderTarget(null),this.fsQuad.render(e)):(e.setRenderTarget(t),e.clear(),this.fsQuad.render(e)),this.scene.overrideMaterial=null,e.setClearColor(this._oldClearColor),e.setClearAlpha(n),e.autoClear=o}}]),r}(d.b)}}]);