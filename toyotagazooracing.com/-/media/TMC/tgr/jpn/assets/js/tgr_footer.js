window.TGR2018 = window.TGR2018 || {};

window.TGR2018.FOOTER_TEMPLATE = {
    SUB: {
        "MENU2": [
            {
                NAME: "ご利用に関して",
                URL: "/jp/attribute/", //遷移先
                TARGET: "_self" //target="_blank" or target="_self"
            },
            {
                NAME: "プライバシーポリシー",
                URL: "//global.toyota/jp/privacy-notice/", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            },
            {
                NAME: "利用規約",
                URL: "/jp/terms/", //遷移先
                TARGET: "_self" //target="_blank" or target="_self"
            },
            {
                NAME: "お問い合わせ",
                URL: "//faq.toyota.jp/", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            },
            {
                NAME: "GR アーカイブ",
                URL: "/jp/archive/", //遷移先
                TARGET: "_self" //target="_blank" or target="_self"
            },
            {
                NAME: "Global Site",
                URL: "/?direct=global", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            },
            {
                NAME: "ホーム",
                URL: "/jp/", //遷移先
                TARGET: "_self" //target="_blank" or target="_self"
            }
        ],
        "LOGOS": [
            {
                THUMB: '/pages/contents/jp/tgr-asset/image/logos/logo_toyota.png', //サムネイル
                NAME: "TOYOTA",
                URL: "https://www.toyota.co.jp/", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            },
            {
                THUMB: '/pages/contents/jp/tgr-asset/image/logos/logo_lexus.png', //サムネイル
                NAME: "LEXUS",
                URL: "https://lexus.jp/", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            },
            {
                THUMB: '/pages/contents/jp/tgr-asset/image/logos/logo_gazoo.png', //サムネイル
                NAME: "GAZOO",
                URL: "https://gazoo.com/", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            },
            {
                THUMB: '/pages/contents/jp/tgr-asset/image/logos/logo_fujispeedway.png', //サムネイル
                NAME: "FUJI SPEEDWAY",
                URL: "https://www.fsw.tv/", //遷移先
                TARGET: "_blank" //target="_blank" or target="_self"
            }
        ]
    },
    LOGO: { //TOYOTA GAZOO Racing
        NAME: 'TOYOTA GAZOO Racing',
        SRC: '/pages/contents/jp/tgr-asset/image/logo.svg', //ファイルソース
        URL: '/jp/' //遷移先
    },
    COPYRIGHT: 'COPYRIGHT&copy; TOYOTA MOTOR CORPORATION.<br class="sp-show"> All Rights Reserved.'
};

window.TGR2018.FooterTemplateGenerator = function () {
    this.baseSrc = '<footer id="global-footer">' +
                        '<div class="gf-block">' +
                            '<div class="gf-block-foot">' +
                                '<div class="tpl__container">' +
                                    '<div class="gf-unit">' +
                                        '<div class="gf-unit-head">' +
                                            '<nav class="gf-sub-navigation gf-navigation">' +
//                                                '<div class="footer-banner sp-show" style="margin: 0 auto;padding: 25px 15px 0;"><a href="" onclick="sc(\'gazooracing:ja:footer:\')"><img alt="" src="/pages/contents/jp/tgr-asset/image/common/footerbanner-.jpg" style="width: 100%;"></a></div>' +
                                                '<ul id="gf-sub-navigation-menu1" class="gf-sub-navigation-menu"></ul>' +
                                                '<ul id="gf-sub-navigation-logos" class="gf-sub-navigation-menu"></ul>' +
                                            '</nav>' +
                                        '</div>' +
                                        '<div class="gf-unit-foot">' +
                                            '<ul id="gf-sub-navigation-menu2" class="gf-sub-navigation-menu"></ul>' +
                                            '<p>'+window.TGR2018.FOOTER_TEMPLATE.COPYRIGHT+'</p>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<a id="page-go-up" class="hover-opacity1" href="#"><span><span>GO UP</span></span></a>' +
                    '</footer>';

    $('#footer').html( this.baseSrc );

    this.init();
};


window.TGR2018.FooterTemplateGenerator.prototype = {
    init: function () {
        var src2 = '',
            src3 = '',
            sub = window.TGR2018.FOOTER_TEMPLATE.SUB,
            sub2 = sub.MENU2,
            sub2Length = sub2.length,
            logos = sub.LOGOS,
            logosLength = logos.length,
            logosSrc = '',
            i = 0;

        src2 +=
            '<div id="gfs-ourstory" class="gfs-block gfs-col1">'+
              '<p class="gfs-title"><a href="/jp/our-story/" target="_self">OUR STORY</a></p>'+
              '<div class="gfs-nav">'+
                '<ul class="gfs-nav-list gfs-list-col1">'+
                  '<li><a href="/pages/special/fivecontinentsdrive/" target="_self">5大陸走破</a></li>'+
                  '<li><a href="/jp/insidegr/" target="_self">INSIDE GR</a></li>'+
                  '<li><a href="/jp/miraikaigi/" target="_self">未来会議</a></li>'+
                '</ul>'+
              '</div>'+
            '</div>'+

            '<div id="gfs-carlineup" class="gfs-block gfs-col5">'+
              '<p class="gfs-title"><a href="/jp/carlineup/" target="_self">GR LINEUP</a></p>'+
              '<div class="gfs-nav">'+
                '<ul class="gfs-nav-list gfs-list-col5">'+ //liを5の倍数+1個にする（GR LINEUP TOPは非表示の為）
                  '<li><a href="/jp/carlineup/" target="_self">GR LINEUP TOP</a></li>'+
                  '<li><a href="/jp/grmn/yaris/" target="_self">GRMN YARIS</a></li>'+
                  '<li><a href="/jp/gr/corolla/" target="_self">GR COROLLA</a></li>'+
                  '<li><a href="/jp/gr/86/" target="_self">GR86</a></li>'+
                  '<li><a href="/jp/gr/yaris/" target="_self">GR YARIS</a></li>'+
                  '<li><a href="/jp/gr/supra/" target="_self">GR SUPRA</a></li>'+
                  '<li><a href="/jp/gr/yariscrossgrs/" target="_self">YARIS CROSS GR SPORT</a></li>'+
                  '<li><a href="/jp/gr/hiluxgrs/" target="_self">HILUX GR SPORT</a></li>'+
                  '<li><a href="/jp/gr/landcruisergrs/" target="_self">LAND CRUISER GR SPORT</a></li>'+
                  '<li><a href="/jp/gr/copengrs/" target="_self">COPEN GR SPORT</a></li>'+
                  '<li><a href="/jp/gr/c-hrgrs/" target="_self">C-HR GR SPORT</a></li>'+
                  '<li><a href="/jp/gr/grspriusphv/" target="_self">PRIUS PHV GR SPORT</a></li>'+
                  '<li><a href="/jp/gr/grparts/" target="_self">GR PARTS</a></li>'+
                  '<li><a href="/jp/gr/heritage/" target="_self">GR HERITAGE PARTS</a></li>'+
                  //表示位置がずれる場合は下記を（場合によって複数個）入れる
                  '<li class="display_pc">&nbsp;</li>'+
                  '<li class="display_pc">&nbsp;</li>'+
                  //'<li class="display_pc">&nbsp;</li>'+
                '</ul>'+
              '</div>'+
            '</div>'+

            '<div id="gfs-motorsports" class="gfs-block gfs-col5">'+
              '<p class="gfs-title"><a href="/jp/motorsports/" target="_self">MOTORSPORTS</a></p>'+
              '<div class="gfs-nav">'+
                '<ul class="gfs-nav-list gfs-list-col5">'+
                  '<li><a href="/jp/motorsports/" target="_self">MOTORSPORTS TOP</a></li>'+
                  '<li><a href="/jp/wrc/" target="_self">WRC - FIA世界ラリー選⼿権</a></li>'+
                  '<li><a href="/jp/wec/" target="_self">WEC - FIA世界耐久選⼿権</a></li>'+
                  '<li><a href="/jp/dakar/" target="_self">ダカールラリー</a></li>'+
                  '<li><a href="/jp/nurburgring/" target="_self">ニュルブルクリンク24時間<br>レース</a></li>'+
                  '<li><a href="/jp/supergt/" target="_self">SUPER GT</a></li>'+
                  '<li><a href="/jp/superformula/" target="_self">SUPER FORMULA</a></li>'+
                  '<li><a href="/jp/jrc/" target="_self">全日本ラリー選⼿権</a></li>'+
                  '<li><a href="/jp/supertaikyu/" target="_self">スーパー耐久シリーズ</a></li>'+
                  '<li><a href="/jp/86brz/" target="_self">GR86/BRZ Cup</a></li>'+
                  '<li><a href="/jp/yariscup/" target="_self">Yaris Cup</a></li>'+
                  '<li><a href="/jp/rallychallenge/" target="_self">ラリーチャレンジ</a></li>'+
                  '<li><a href="/jp/e-motorsports/" target="_self">e-Motorsports</a></li>'+
                  '<li><a href="/jp/tdp/" target="_self">TGRドライバー・チャレンジ・プログラム</a></li>'+
                  '<li><a href="/jp/challengeprogram_rally/" target="_self">WRCチャレンジプログラム</a></li>'+
                  '<li><a href="/jp/customer-motorsports/" target="_self">CUSTOMER MOTORSPORTS</a></li>'+
                  '<li><a href="/jp/motorsports/driver/" target="_self">ドライバー情報</a></li>'+
                  '<li><a href="/jp/gallery/wallpaper-calendar/" target="_self">壁紙カレンダー</a></li>'+
                  '<li><a href="/jp/motorsports/tvschedule/" target="_self">モータースポーツ番組</a></li>'+
                  '<li><a href="/jp/motorsports/ticket/" target="_self">観戦チケット購入ガイド</a></li>'+
                  //表示位置がずれる場合は下記を（場合によって複数個）入れる
                  '<li class="display_pc">&nbsp;</li>'+
                  '<li class="display_pc">&nbsp;</li>'+
                  '<li class="display_pc">&nbsp;</li>'+
                  '<li class="display_pc">&nbsp;</li>'+
                  '<li class="display_pc">&nbsp;</li>'+
                  //'<li class="display_pc">&nbsp;</li>'+
                '</ul>'+
              '</div>'+
            '</div>'+

            '<div id="gfs-news" class="gfs-block gfs-col1">'+
              '<p class="gfs-title"><a href="/jp/newsroom/" target="_self">NEWSROOM</a></p>'+
              '<div class="gfs-nav">'+
                '<ul class="gfs-nav-list gfs-list-col1">'+
                  '<li><a href="/jp/news/" target="_self">NEWS</a></li>'+
                  '<li><a href="/jp/pressrelease/" target="_self">PRESS RELEASE</a></li>'+
                '</ul>'+
              '</div>'+
            '</div>'+

            '<div id="gfs-enjoy" class="gfs-block gfs-col6">'+
              '<p class="gfs-title"><a href="/jp/enjoy/" target="_self">ENJOY!</a></p>'+
              '<div class="gfs-nav">'+
                '<div class="gfs-col1 enjoy-top">'+
                  '<ul class="gfs-nav-list gfs-list-col1">'+
                    '<li><a href="/jp/enjoy/" target="_self">ENJOY TOP</a></li>'+
                  '</ul>'+
                '</div>'+
                '<div class="gfs-col3">'+
                  '<p class="gfs-subtitle">EVENT</p>'+
                  '<ul class="gfs-nav-list gfs-list-col3">'+
                    '<li><a href="/jp/event/" target="_self">EVENT TOP</a></li>'+
                    '<li><a href="/jp/gr-gymkhana/" target="_self">ジムカーナに挑戦しよう!!</a></li>'+
                    '<li><a href="/jp/drivingexperience/" target="_self">TGRD</a></li>'+
                    '<li><a href="/jp/tgrf/" target="_self">TGRF</a></li>'+
                    '<li><a href="/jp/tgrp/" target="_self">TGRP</a></li>'+
                    '<li><a href="/jp/event/msj/2019/" target="_self">モータスポーツジャパン</a></li>'+
                    '<li><a href="/jp/supergt/lgda/" target="_self">LGDA夏祭り</a></li>'+
                    '<li><a href="/jp/eventexhibition/tokyoautosalon/" target="_self">東京オートサロン</a></li>'+
                    '<li><a href="/jp/eventexhibition/osakaautomesse/" target="_self">大阪オートメッセ</a></li>'+
                    '<li><a href="https://www.toyota.co.jp/jp/about_toyota/facility/toyota_kaikan/" target="_blank">トヨタ会館ミュージアム</a></li>'+
                  '</ul>'+
                '</div>'+
                '<div class="gfs-col2">'+
                  '<p class="gfs-subtitle">GOODS</p>'+
                  '<ul class="gfs-nav-list gfs-list-col2">'+
                    '<li><a href="/jp/goods/" target="_self">OFFICIAL GOODS</a></li>'+
                    '<li><a href="/jp/goods/motorsports/" target="_self">WRC</a></li>'+
                    '<li><a href="/jp/goods/motorsports/" target="_self">WEC</a></li>'+
                    '<li><a href="/jp/goods/motorsports/" target="_self">ニュルブルクリンク24時間<br>レース</a></li>'+
                    '<li><a href="/jp/goods/motorsports/" target="_self">SPORTS</a></li>'+
                    '<li><a href="/jp/goods/motorsports/" target="_self">CLASSIC</a></li>'+
                    '<li><a href="/jp/goods/tgrcar/" target="_self">GR SUPRA</a></li>'+
                    '<li><a href="/jp/goods/tgrcar/" target="_self">GR YARIS</a></li>'+
                  '</ul>'+
                '</div>'+
                '<div class="gfs-col1">'+
                  '<p class="gfs-subtitle">COLUMN</p>'+
                  '<ul class="gfs-nav-list gfs-list-col1">'+
                    '<li><a href="/jp/blogcolumn/column/" target="_self">木下隆之のクルマ連載コラム「クルマ・スキ・トモニ」</a></li>'+
                    '<li><a href="/jp/wrc/column/" target="_self">モータースポーツジャーナリスト古賀敬介の「WRCな日々」</a></li>'+
                    '<li><a href="/jp/blogcolumn/column2/" target="_self">レポーター（お）ねーさんのモタスポコラム</a></li>'+
                    '<li><a href="/jp/kumakichi/" target="_self">くま吉ワールド</a></li>'+
                    '<li><a href="https://ameblo.jp/tsutomutojo/" target="_blank">エンジニア東條のブログ</a></li>'+
                  '</ul>'+
                '</div>'+
              '</div>'+
            '</div>';

        for( i = 0; i < sub2Length; i++ ) src3 += this.addSubTemp( sub2, i );
        for( i = 0; i < logosLength; i++ ) logosSrc += this.addLogoTemp( logos, i );

        $('#gf-sub-navigation-menu1').html(src2);
        $('#gf-sub-navigation-menu2').html(src3);
        $('#gf-sub-navigation-logos').html(logosSrc);

    },
    addSubTemp: function(sub,index){
        var src = '';

        src += '<li><a href="'+sub[index].URL+'" target="'+sub[index].TARGET+'">'+sub[index].NAME+'</a></li>'

        return src;
    },
    addLogoTemp: function(logos,index){
        var src = '';

        src += '<li><a href="'+logos[index].URL+'" target="'+logos[index].TARGET+'"><img src="'+logos[index].THUMB+'" alt="'+logos[index].NAME+'"></a></li>'

        return src;
    }
}


window.TGR2018.FooterNav = function(){
  this.$trigger = $('.gfs-title');
  this.click = this.click.bind(this);
  this.$trigger.on('click', this.click);
  this.BREAKPOINT = 870;
  this.isSP = window.matchMedia('(max-width:'+this.BREAKPOINT+'px)').matches;

  // リサイズしたら表示位置を再取得
  var self = this;
  $(window).on('resize', function(){
    var oldMode = self.isSP;
    var currentMode = window.matchMedia('(max-width:'+self.BREAKPOINT+'px)').matches;
    if( oldMode !== currentMode ) {
      $('.gfs-nav').removeAttr('style');
      self.isSP = currentMode;
      $('.gfs-block').removeClass('is-active');
    }
  });
};

window.TGR2018.FooterNav.prototype = {
  click : function(e) {
    //PCサイズは無視
    if( !this.isSP ) { return; }

    e.preventDefault();
    var $parent = $(e.target).parents('.gfs-block');
    $parent.toggleClass('is-active');
    $parent.find('.gfs-nav').stop().slideToggle(200);
  }
};




new window.TGR2018.FooterTemplateGenerator();
new window.TGR2018.FooterNav();

!function(e){function n(r){if(t[r])return t[r].exports;var o=t[r]={i:r,l:!1,exports:{}};return e[r].call(o.exports,o,o.exports,n),o.l=!0,o.exports}var t={};n.m=e,n.c=t,n.i=function(e){return e},n.d=function(e,t,r){n.o(e,t)||Object.defineProperty(e,t,{configurable:!1,enumerable:!0,get:r})},n.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(t,"a",t),t},n.o=function(e,n){return Object.prototype.hasOwnProperty.call(e,n)},n.p="",n(n.s=15)}([function(e,n,t){"use strict";function r(e,n){if(!(e instanceof n))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,n){for(var t=0;t<n.length;t++){var r=n[t];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(n,t,r){return t&&e(n.prototype,t),r&&e(n,r),n}}(),a=function(){function e(){r(this,e)}return o(e,null,[{key:"wait",value:function(e){var n=$.Deferred();return setTimeout(function(){n.resolve()},e),n.promise()}},{key:"getCubicCurve",value:function(e,n,t,r){return CustomEase.create("custom","M0,0 C"+Number(e)+","+Number(n)+" "+Number(t)+","+Number(r)+" 1,1")}}]),e}();n.a=a},,,,,,function(e,n,t){"use strict";function r(e,n){if(!(e instanceof n))throw new TypeError("Cannot call a class as a function")}var o=t(0),a=function(){function e(e,n){for(var t=0;t<n.length;t++){var r=n[t];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(n,t,r){return t&&e(n.prototype,t),r&&e(n,r),n}}(),i=function(){function e(){r(this,e),this.anchorScrollStart=function(e){},this.anchorScrollCallBack=function(e){setTimeout(function(){$(window).scrollTop()>50&&$("body").addClass("header-hide")},100)}}return a(e,[{key:"run",value:function(){var n=this;$(document).on("click.PageAnchorScroll",".js-anchor-trigger",function(t){t.preventDefault();var r=$(t.currentTarget),o=r.attr("href"),a=r.data("anchor-adjust");$(".ctn-kind-menu>li").removeClass("is-menu-open"),n.anchorScrollStart(t),e.anchorScroll(o,a).done(function(){n.anchorScrollCallBack(t)})})}}],[{key:"anchorScroll",value:function(e){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,t=$.Deferred();return TweenMax.to($("body,html"),.7,{scrollTop:$(e).offset().top+1-n,ease:o.a.getCubicCurve(.6,0,.3,1),onComplete:function(){t.resolve()}}),t.promise()}}]),e}();n.a=i},function(e,n,t){"use strict";function r(e,n){if(!(e instanceof n))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,n){for(var t=0;t<n.length;t++){var r=n[t];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(n,t,r){return t&&e(n.prototype,t),r&&e(n,r),n}}(),a=function(){function e(){r(this,e),this.$target=$("body"),this.$chekerName=$("[data-page-name]"),this.$chekerKind=$("[data-page-kind]")}return o(e,[{key:"run",value:function(){if(this.$chekerKind.length){this.pageKind=this.$chekerKind.attr("data-page-kind");var e="page-kind-is-"+this.pageKind;this.$target.addClass(e);var n=".gh-gm-"+this.pageKind;$(n).addClass("is-current")}if(this.$chekerName.length){this.pageContentType=this.$chekerName.attr("data-page-name");var t="page-name-is-"+this.pageContentType;this.$target.addClass(t)}}}]),e}();n.a=a},,function(e,n,t){"use strict";function r(e,n){if(!(e instanceof n))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,n){for(var t=0;t<n.length;t++){var r=n[t];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(n,t,r){return t&&e(n.prototype,t),r&&e(n,r),n}}(),a=function(){function e(){r(this,e),this.trigger=$(".js-sp-accordion-trigger"),this.getTarget=$(".js-sp-accordion-get-target"),this.target=$(".js-sp-accordion-target")}return o(e,[{key:"run",value:function(){var e=this;$(document).on("click.SpAccordion",".js-sp-accordion-trigger",function(n){n.preventDefault();var t=$(n.currentTarget),r=t.parents(".js-sp-accordion-target");e._check(r)?e._close(r):e._open(r)})}},{key:"_open",value:function(e){var n=e.find(".js-sp-accordion-get-target").innerHeight()+50;e.css({height:n}).addClass("is-active")}},{key:"_close",value:function(e){e.css({height:50}).removeClass("is-active")}},{key:"_check",value:function(e){return e.hasClass("is-active")}},{key:"destroy",value:function(){$(document).off("click.SpAccordion",".js-sp-accordion-trigger"),this.target.css({height:""}).removeClass("is-active")}}]),e}();n.a=a},,function(e,n,t){"use strict";function r(e,n){if(!(e instanceof n))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,n){for(var t=0;t<n.length;t++){var r=n[t];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(n,t,r){return t&&e(n.prototype,t),r&&e(n,r),n}}(),a=function(){function e(){r(this,e),this.target=$("a")}return o(e,[{key:"run",value:function(){$(document).on("touchstart.SpTapAction","a",function(e){$(e.currentTarget).addClass("is-touched")}),$(document).on("touchend.SpTapAction","a",function(e){$(e.currentTarget).removeClass("is-touched")})}}]),e}();n.a=a},,,,function(e,n,t){"use strict";Object.defineProperty(n,"__esModule",{value:!0});var r=t(0),o=t(9),a=t(11),i=t(6),c=t(7);window.TGR2018=window.TGR2018||{},(TGR2018.MOBILE||TGR2018.TABLET)&&(TGR2018.spTapAction=new a.a,TGR2018.spTapAction.run()),TGR2018.pageAnchorScroll=new i.a,TGR2018.spAcc=new o.a,TGR2018.pageAnchorScroll.run(),$(window).on("resize",function(){TGR2018.header.resize(),!TGR2018.isPc&&TGR2018.isCurrentPc&&(TGR2018.isCurrentPc=!1,TGR2018.gNav.destroy(),TGR2018.spGNav.run(),TGR2018.spAcc.run()),TGR2018.isPc&&!TGR2018.isCurrentPc&&(TGR2018.isCurrentPc=!0,TGR2018.spGNav.destroy(),TGR2018.spAcc.destroy(),TGR2018.gNav.run());var e=void 0;e=window.matchMedia("(min-width:871px)").matches?$("#global-header").innerHeight():"none"!==$("#contents-top-navigation").css("display")?$(".sp-global-menu-trigger-container").innerHeight()+$("#contents-top-navigation").innerHeight():$(".sp-global-menu-trigger-container").innerHeight(),$("#main").css({"margin-top":e}),$("#header").css({height:"0"})}),$(window).on("scroll",function(){var e=$(window).scrollTop();TGR2018.header.action(e)}),$(window).trigger("resize"),$(document).on("click","#page-go-up",function(e){e.preventDefault();var n=n||null;null!==n?n.to($("html,body"),.7,{scrollTop:0,ease:r.a.getCubicCurve(.6,.3,0,1)}):$("html,body").animate({scrollTop:0},500)}),setTimeout(function(){$(window).trigger("resize")},1500),TGR2018.pageKindChecker=new c.a,TGR2018.pageKindChecker.run(),TGR2018.synchronizeHover.run(),TGR2018.isPc?TGR2018.gNav.run():(TGR2018.isCurrentPc=!1,TGR2018.spGNav.run(),TGR2018.spAcc.run())}]);


/* imagezoomsl */
(function(){
    var userAgent=window.navigator.userAgent.toLowerCase();
    if(userAgent.indexOf('ipad')!= -1||userAgent.indexOf('iphone')!=-1||userAgent.indexOf('Android')!=-1){
    }else{
        $(window).on('load resize', function(){
            var myTimer = 0;
            $(window).on('load resize',function(){
                if (myTimer > 0) {
                    clearTimeout(myTimer);
                }
                myTimer = setTimeout(function () {
                    manageImagezoomsl();
                }, 200);
            });

            function manageImagezoomsl() {
                var myHeight = $('#global-header').height();
                $('.tracker, .round-loupe, .statusdiv')
                    .css('margin-top', -myHeight);
            }
        }) // on load resize
    }
}())


/* プレスリリースにSDGsのボイラープレート設置　2020.9.1～ */
$(window).on("load", (function(){
  if(document.URL.match("/release/|/pressrelease/")) {
    $('#boiler-plate').append(
      '<a href="https://global.toyota/jp/sustainability/sdgs/" target="_blank">'+
      '<img alt="SUSTAINABLE DEVELOPMENT GOALS" src="/pages/contents/jp/release/images/boiler-plate.png">'+
      '</a>'
    );
    $('[id=contents-body]').css('padding-bottom','0');
    $('#contents-body .section.normargin').css('margin-bottom','0');
    $('#contents-footer').css({'padding':'5%','background':'#fff'});
    $('#sdgs').css({'max-width':'600px','margin':'0 auto'});
    $('#sdgs img').css('width','100%');
  }
}));
/* アイコンがある場合
   該当ページの「フッターHTML」に以下を直書きして対応
   <div id="sdgs">
   <div id="boiler-plate"></div>
   <div id="sdgs-icon">
     ここに必要な内容を記述
   </div>
   </div>
-------------------------------------------------- */
