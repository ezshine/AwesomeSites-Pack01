(window.webpackJsonp=window.webpackJsonp||[]).push([[12],{594:function(e,t,l){var content=l(649);content.__esModule&&(content=content.default),"string"==typeof content&&(content=[[e.i,content,""]]),content.locals&&(e.exports=content.locals);(0,l(87).default)("497d27f5",content,!0,{sourceMap:!1})},648:function(e,t,l){"use strict";l(594)},649:function(e,t,l){var n=l(86)(!1);n.push([e.i,'[data-v-6c5d651c]:export{base-width--small:320px;base-width--medium:768px;base-width--large:1600px;base-font-size--small:1vw;base-font-size--medium:1vw;base-font-size--large:1vw;max-width--small:none;max-width--medium:none;max-width--large:none}@media(min-width:0){html[data-v-6c5d651c]:before{display:none;content:"small"}}@media(min-width:500px){html[data-v-6c5d651c]:before{display:none;content:"medium"}}@media(min-width:850px){html[data-v-6c5d651c]:before{display:none;content:"large"}}.page-home[data-v-6c5d651c]{position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none}',""]),e.exports=n},680:function(e,t,l){"use strict";l.r(t);l(31),l(24),l(30),l(15),l(38),l(26),l(39);var n=l(8),o=(l(104),l(63),l(70),l(48)),r=l(69),c=l(574),d=l(566),h=l(601),v=l(604),m=l(605),f=l(602),w=l(603);function O(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(object);e&&(l=l.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,l)}return t}var $={mixins:[c.a,d.a],computed:function(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?O(Object(source),!0).forEach((function(t){Object(n.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):O(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}({},Object(o.b)({data:"data/data",collectionItems:"collection/items",collectionItem:"collection/current"})),watch:{collectionItems:function(e){this.$root.webglApp.setCollectedItems(e)}},mounted:function(){var e=this;this.setupEventListeners(),window.debugLastCollection=function(){for(var t=[],i=0;i<24;i++)t.push(i);e.$store.dispatch("collection/setItems",t)},setTimeout((function(){}),1e3)},beforeDestroy:function(){var e,t,l,n,o;null===(e=this.timelineIn)||void 0===e||e.kill(),null===(t=this.timelineOut)||void 0===t||t.kill(),null===(l=this.timelineStart)||void 0===l||l.kill(),null===(n=this.timelineExitOverview)||void 0===n||n.kill(),null===(o=this.timelineOpenOverview)||void 0===o||o.kill(),this.removeEventListeners()},methods:{transitionIn:function(e,t){var l,n;null===(l=this.timelineIn)||void 0===l||l.kill(),null===(n=this.timelineOut)||void 0===n||n.kill(),this.timelineIn=new r.b.timeline,this.$refs.tutorial&&this.timelineIn.add(this.$refs.tutorial.transitionIn(),0),e&&this.timelineIn.call(e,null)},transitionOut:function(e,t){var l,n;null===(l=this.timelineIn)||void 0===l||l.kill(),null===(n=this.timelineOut)||void 0===n||n.kill(),this.timelineOut=new r.b.timeline,e&&this.timelineOut.call(e,null)},start:function(){this.$root.webglApp.enableNavigation(),this.$root.webglApp.enableSelection(),this.$root.webglApp.setCollectedItems(this.collectionItems),this.timelineStart=new r.b.timeline,this.$refs.tutorial&&this.timelineStart.add(this.$refs.tutorial.transitionOut(),0),this.$refs.collection&&this.timelineStart.add(this.$refs.collection.transitionIn(),.5),this.timelineStart.add(this.$root.webglApp.showOverlays(),1)},openOverview:function(){var e,t,l,n;this.$root.webglApp.disableNavigation(),this.$root.webglApp.disableSelection(),this.$root.webglApp.goToOverview(),this.$root.webglApp.smallFocus(),null===(e=this.timelineExitOverview)||void 0===e||e.kill(),null===(t=this.timelineStart)||void 0===t||t.kill(),null===(l=this.timelineExitDetails)||void 0===l||l.kill(),null===(n=this.timelineOpenDetails)||void 0===n||n.kill(),this.timelineOpenOverview=new r.b.timeline,this.$refs.collection&&this.timelineOpenOverview.add(this.$refs.collection.transitionOut(),0),this.$refs.overview&&this.timelineOpenOverview.add(this.$refs.overview.transitionIn(),1)},exitOverview:function(e){var t,l,n,o,c=this;null===(t=this.timelineOpenOverview)||void 0===t||t.kill(),null===(l=this.timelineStart)||void 0===l||l.kill(),null===(n=this.timelineExitDetails)||void 0===n||n.kill(),null===(o=this.timelineOpenDetails)||void 0===o||o.kill(),this.timelineExitOverview=new r.b.timeline,this.$refs.overview&&this.timelineExitOverview.add(this.$refs.overview.transitionOut(),0),this.$refs.collection&&this.timelineExitOverview.add(this.$refs.collection.transitionIn(),1),this.timelineExitOverview.call((function(){c.$root.webglApp.leaveOverview(e),c.$root.webglApp.noFocus()}),null,.5),this.timelineExitOverview.call((function(){c.$root.webglApp.enableNavigation(),c.$root.webglApp.enableSelection()}),null,1.5)},openDetails:function(e,t,l){var n,o,c=this;this.$root.webglApp.playSelectionFeedback(e,t),this.$root.webglApp.disableNavigation(),this.$root.webglApp.disableSelection(),this.$root.webglApp.fullFocus(),null===(n=this.timelineExitDetails)||void 0===n||n.kill(),null===(o=this.timelineOpenDetails)||void 0===o||o.kill();var d=t?1:0;d=l?2:d,this.timelineOpenDetails=new r.b.timeline,l&&this.$refs.collection&&this.timelineOpenDetails.add(this.$refs.collection.collectionCompleted(),.4),t&&!l&&this.timelineOpenDetails.call((function(){c.$soundManager.playSound("sound-single-bag",{volume:.8,frequencyOffset:!0,frequencyIndex:e})}),null,0),l&&this.timelineOpenDetails.call((function(){c.$soundManager.playSound("sound-all-bags",{volume:.8})}),null,0),this.$refs.collection&&this.timelineOpenDetails.add(this.$refs.collection.transitionOut(),l?2:0),this.timelineOpenDetails.call((function(){c.$root.webglApp.goToDetails(c.collectionItem)}),null,0+d),this.$refs.detailsMobile&&this.timelineOpenDetails.add(this.$refs.detailsMobile.transitionIn(),1+d),this.$refs.detailsDesktop&&this.timelineOpenDetails.add(this.$refs.detailsDesktop.transitionIn(),1+d),this.timelineOpenDetails.call((function(){c.$root.webglApp.enableBackNavigation()}),null,1+d)},exitDetails:function(){var e,t,l=this;this.$root.webglApp.disableBackNavigation(),null===(e=this.timelineExitDetails)||void 0===e||e.kill(),null===(t=this.timelineOpenDetails)||void 0===t||t.kill(),this.timelineExitDetails=new r.b.timeline,this.$refs.detailsMobile&&this.timelineExitDetails.add(this.$refs.detailsMobile.transitionOut(),0),this.$refs.detailsDesktop&&this.timelineExitDetails.add(this.$refs.detailsDesktop.transitionOut(),0),this.$refs.collection&&this.timelineExitDetails.add(this.$refs.collection.transitionIn(),1),this.timelineExitDetails.call((function(){l.$root.webglApp.leaveDetails(l.collectionItem),l.$root.webglApp.noFocus()}),null,.5),this.timelineExitDetails.call((function(){l.$root.webglApp.enableNavigation(),l.$root.webglApp.enableSelection()}),null,1.5)},setupEventListeners:function(){this.$root.$on("webgl:select",this.selectHandler)},removeEventListeners:function(){this.$root.$off("webgl:select",this.selectHandler)},tutorialCompletedHandler:function(){this.start()},clickOverviewHandler:function(){this.openOverview()},clickExitOverviewHandler:function(e){var t=e&&e.customData?e.customData.index:null;this.exitOverview(t)},clickExitDetailsHandler:function(){this.exitDetails()},selectHandler:function(e){var t=!this.collectionItems.includes(e),l=t&&24===this.collectionItems.length;this.$store.dispatch("collection/addItem",e),this.$store.dispatch("collection/setCurrent",e),this.openDetails(e,t,l)}},components:{Tutorial:h.a,Collection:v.a,DetailsDesktop:m.a,DetailsMobile:f.a,Overview:w.a}},D=$,x=(l(648),l(58)),component=Object(x.a)(D,(function(){var e=this,t=e._self._c;e._self._setupProxy;return t("div",{staticClass:"page page-home"},[t("Tutorial",{ref:"tutorial",attrs:{data:e.data.fields.viewTutorial},on:{completed:e.tutorialCompletedHandler}}),e._v(" "),t("DetailsDesktop",{ref:"detailsDesktop",on:{clickExit:e.clickExitDetailsHandler}}),e._v(" "),t("DetailsMobile",{ref:"detailsMobile",on:{clickExit:e.clickExitDetailsHandler}}),e._v(" "),t("Overview",{ref:"overview",on:{clickExit:e.clickExitOverviewHandler}}),e._v(" "),t("Collection",{ref:"collection",on:{clickOverview:e.clickOverviewHandler}})],1)}),[],!1,null,"6c5d651c",null);t.default=component.exports}}]);