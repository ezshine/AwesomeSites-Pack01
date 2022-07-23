window.TGR2018 = window.TGR2018 || {};

window.TGR2018.HEADER_TEMPLATE = {
    SUB: {
        LOGO: { //TOYOTA GAZOO Racing
            NAME: 'TOYOTA GAZOO Racing',
            SRC: '/pages/contents/jp/tgr-asset/image/logo.png', //ファイルソース
            URL: '/jp/', //遷移先
            SC: 'gazooracing:gras:newgnav:etc:headlogo', //クリックカウント
        },
        INFORMATION :[ //INFORMATION
            {
                NAME: 'OUR STORY',
                CLASS: '', //アイコンなどのクラス追加*/
                URL: '/jp/our-story', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:our-story', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: 'gh-ourstory',
                HIERARCHY : [
                  '/jp/our-story/',
                  '/pages/special/fivecontinentsdrive/',
                  '/pages/special/akiosdrive/'
                ]
            },
            {
                NAME: 'GR LINEUP',
                CLASS: 'js-subnav', //アイコンなどのクラス追加
                URL: '/jp/carlineup/', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:carlineup', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: 'gh-carlineup',
                HIERARCHY : [
                  '/jp/carlineup/',
                  '/jp/86/',
                  '/jp/gr/',
                  '/jp/all-cars/',
                  '/pages/grmn/'
                ]
            },
            {
                NAME: 'MOTORSPORTS',
                CLASS: 'js-subnav', //アイコンなどのクラス追加
                URL: '/jp/motorsports/', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:other-mortor-sports', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: 'gh-motorsports',
                HIERARCHY : [
                  '/jp/motorsports/',
                  '/jp/wec/',
                  '/jp/nurburgring/',
                  '/jp/supergt/',
                  '/jp/superformula/',
                  '/jp/wrc/',
                  '/jp/jrc/',
                  '/jp/dakar/',
                  '/jp/e-motorsports/',
                  '/jp/lexus-customer-racing/',
                  '/jp/tgr-customer-motorsports/',
                  '/jp/86brz/',
                  '/jp/yariscup/',
                  '/jp/rallychallenge/',
                  '/jp/tdp/',
                  '/jp/wec_challengeprogram/',
                  '/jp/challengeprogram_rally/',
                  '/jp/juniorformula/',
                  '/jp/motorsports/driver/',
                  '/jp/gallery/wallpaper-calendar/'
                ]
            },
            {
                NAME: 'NEWSROOM',
                CLASS: '', //アイコンなどのクラス追加*/
                URL: '/jp/newsroom/', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:newsroom', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: 'gh-newsroom',
                HIERARCHY : [
                  '/jp/newsroom/',
                  '/jp/pressrelease/',
                  '/jp/news/'
                ]
            },
            {
                NAME: 'ENJOY!',
                CLASS: 'js-subnav', //アイコンなどのクラス追加
                URL: '/jp/enjoy/', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:enjoy', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: 'gh-enjoy',
                HIERARCHY : [
                  '/jp/enjoy/',
                  '/jp/event/',
                  '/jp/gr-gymkhana/',
                  '/jp/drivingexperience/',
                  '/jp/tgrf/',
                  '/jp/tgrp/',
                  '/jp/woman/',
                  '/jp/goods/',
                  '/jp/kumakichi/',
                  '/jp/blogcolumn/column/',
                  '/jp/blogcolumn/column2/',
                  '/jp/eventexhibition/tokyoautosalon/',
                  '/jp/eventexhibition/osakaautomesse/',
                  '/jp/event/msj/'
                ]
            },
            {
                NAME: 'SCHEDULE',
                CLASS: 'icon icon-schedule', //アイコンなどのクラス追加
                URL: '/jp/calendar/', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:schedule', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: '',
            },
            // {
            //     NAME: 'GLOBAL',
            //     CLASS: 'icon icon-global-site', //アイコンなどのクラス追加
            //     URL: '/?direct=global', //遷移先
            //     SC: 'gazooracing:gras:newgnav:etc:globalsite', //クリックカウント
            //     TARGET: '_blank', //target="_blank" or target="_self"
            //     DATA_TARGET: '',
            // },
            {
                NAME: 'SEARCH',
                CLASS: 'icon icon-search modal-open', //アイコンなどのクラス追加
                URL: '', //遷移先
                SC: 'gazooracing:gras:newgnav:etc:site-search', //クリックカウント
                TARGET: '_self', //target="_blank" or target="_self"
                DATA_TARGET: 'search-form',
            },
        ]
    }
};

window.TGR2018.HeaderTemplateGenerator = function () {
    this.tpl = window.TGR2018.HEADER_TEMPLATE;

    // MAIN
    this.baseSrc = '<header id="global-header">'+
                    '<div class="gh-main-header">'+
                        '<div class="gh-block">'+
                            '<div class="gh-block-head">'+
                                '<div class="tpl__container grid-panel-menu is-between">'+
                                    '<a id="tgr-site-logo" href="'+this.tpl.SUB.LOGO.URL+'" onclick="sc(\''+this.tpl.SUB.LOGO.SC+'\')">'+
                                        '<img src="'+this.tpl.SUB.LOGO.SRC+'" alt="'+this.tpl.SUB.LOGO.NAME+'">'+
                                    '</a>'+
                                    '<nav class="sub-navigation grid-panel-menu">' +
                                        '<ul id="gh-information-menu"></ul>'+
                                        // '<ul id="gh-sns-menu"></ul>'+
                                    '</nav>'+
                                '</div>'+
                            '</div>'+
                        '</div>'+
                    '</div>';

    this.subnav = {};
    /*
    this.subnav['gh-ourstory'] = '<div id="gh-ourstory" class="gh-subnav-block"><div class="gh-subnav-container">'+
                        '<h2><a href="/jp/our-story/" target="_self">OUR STORY</a></h2>'+
                        '<nav class="gh-subnav">'+
                          '<ul class="gh-subnav-list gh-subnav-list-col4">'+
                            '<li><a href="/pages/special/akiosdrive/" target="_self">AKIO&#39;S DRIVE</a></li>'+
                            '<li><a href="/pages/special/fivecontinentsdrive/" target="_self">5大陸走破</a></li>'+
                          '</ul>'+
                        '</nav>'+
                      '</div></div>';
    */
    this.subnav['gh-carlineup'] = '<div id="gh-carlineup" class="gh-subnav-block"><div class="gh-subnav-container">'+
                        '<h2><a href="/jp/carlineup/" target="_self">GR LINEUP</a></h2>'+
                        '<nav class="gh-subnav">'+
                          '<ul class="gh-subnav-list gh-subnav-list-col4">'+
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
                          '</ul>'+
                        '</nav>'+
                      '</div></div>';
    this.subnav['gh-motorsports'] = '<div id="gh-motorsports" class="gh-subnav-block"><div class="gh-subnav-container">'+
                        '<h2><a href="/jp/motorsports/" target="_self">MOTORSPORTS</a></h2>'+
                        '<nav class="gh-subnav">'+
                           '<div class="gh-subnav-col1">'+
                            '<ul class="gh-subnav-list gh-subnav-list-col1">'+
                                '<li><a href="/jp/wrc/" target="_self">WRC - FIA世界ラリー選⼿権</a></li>'+
                                '<li><a href="/jp/wec/" target="_self">WEC - FIA世界耐久選⼿権</a></li>'+
                                '<li><a href="/jp/dakar/" target="_self">ダカールラリー</a></li>'+
                                '<li><a href="/jp/nurburgring/" target="_self">ニュルブルクリンク24時間<br class="pc-show">レース</a></li>'+
                                '<li><a href="/jp/supergt/" target="_self">SUPER GT</a></li>'+
                                '<li><a href="/jp/superformula/" target="_self">SUPER FORMULA</a></li>'+
                            '</ul>'+
                           '</div>'+
                           '<div class="gh-subnav-col1">'+
                            '<ul class="gh-subnav-list gh-subnav-list-col1">'+
                                '<li><a href="/jp/jrc/" target="_self">全日本ラリー選⼿権</a></li>'+
                                '<li><a href="/jp/supertaikyu/" target="_self">スーパー耐久シリーズ</a></li>'+
                                '<li><a href="/jp/86brz/" target="_self">GR86/BRZ Cup</a></li>'+
                                '<li><a href="/jp/yariscup/" target="_self">Yaris Cup</a></li>'+
                                '<li><a href="/jp/rallychallenge/" target="_self">ラリーチャレンジ</a></li>'+
                                '<li><a href="/jp/e-motorsports/" target="_self">e-Motorsports</a></li>'+
                            '</ul>'+
                           '</div>'+
                           '<div class="gh-subnav-col1">'+
                            '<ul class="gh-subnav-list gh-subnav-list-col1">'+
                                '<li><a href="/jp/tdp/" target="_self">TGRドライバー・チャレンジ・<br class="pc-show">プログラム</a></li>'+
                                '<li><a href="/jp/challengeprogram_rally/" target="_self">WRCチャレンジプログラム</a></li>'+
                                '<li><a href="/jp/customer-motorsports/" target="_self">CUSTOMER MOTORSPORTS</a></li>'+
                            '</ul>'+
                           '</div>'+
                           '<div class="gh-subnav-col1">'+
                            '<ul class="gh-subnav-list gh-subnav-list-col1">'+
                                '<li><a href="/jp/motorsports/driver/" target="_self">ドライバー情報</a></li>'+
                                '<li><a href="/jp/gallery/wallpaper-calendar/" target="_self">壁紙カレンダー</a></li>'+
                                '<li><a href="/jp/motorsports/tvschedule/" target="_self">モータースポーツ番組</a></li>'+
                                '<li><a href="/jp/motorsports/ticket/" target="_self">観戦チケット購入ガイド</a></li>'+
                            '</ul>'+
                           '</div>'+
                        '</nav>'+
                      '</div></div>';
    /*
    this.subnav['gh-news'] = '<div id="gh-news" class="gh-subnav-block"><div class="gh-subnav-container">'+
                        '<h2><a href="/jp/news/" target="_self">NEWSROOM</a></h2>'+
                        '<nav class="gh-subnav">'+
                          '<ul class="gh-subnav-list gh-subnav-list-col4">'+
                            '<li><a href="/jp/news/" target="_self">NEWS</a></li>'+
                            '<li><a href="/jp/pressrelease/" target="_self">PRESS RELEASE</a></li>'+
                          '</ul>'+
                        '</nav>'+
                      '</div></div>';
    */
    this.subnav['gh-enjoy'] = '<div id="gh-enjoy" class="gh-subnav-block"><div class="gh-subnav-container">'+
                        '<h2><a href="/jp/enjoy/" target="_self">ENJOY!</a></h2>'+
                        '<nav class="gh-subnav">'+
                          '<div class="gh-subnav-col2">'+
                            '<p class="gh-subnav-title">EVENT</p>'+
                            '<ul class="gh-subnav-list gh-subnav-list-col2">'+
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
                          '<div class="gh-subnav-col1">'+
                            '<p class="gh-subnav-title">GOODS</p>'+
                            '<ul class="gh-subnav-list gh-subnav-list-col1">'+
                              '<li><a href="/jp/goods/" target="_self">OFFICIAL GOODS</a></li>'+
                              '<li><a href="/jp/goods/motorsports/" target="_self">WRC</a></li>'+
                              '<li><a href="/jp/goods/motorsports/" target="_self">WEC</a></li>'+
                              '<li><a href="/jp/goods/motorsports/" target="_self">ニュルブルクリンク24時間<br class="pc-show">レース</a></li>'+
                              '<li><a href="/jp/goods/motorsports/" target="_self">SPORT</a></li>'+
                              '<li><a href="/jp/goods/motorsports/" target="_self">CLASSIC</a></li>'+
                              '<li><a href="/jp/goods/tgrcar/" target="_self">GR SUPRA</a></li>'+
                              '<li><a href="/jp/goods/tgrcar/" target="_self">GR YARIS</a></li>'+
                            '</ul>'+
                          '</div>'+
                          '<div class="gh-subnav-col1">'+
                            '<p class="gh-subnav-title">COLUMN</p>'+
                            '<ul class="gh-subnav-list gh-subnav-list-col1">'+
                              '<li><a href="/jp/blogcolumn/column/" target="_self">木下隆之のクルマ連載コラム<br class="pc-show">「クルマ・スキ・トモニ」</a></li>'+
                              '<li><a href="/jp/wrc/column/" target="_self">モータースポーツジャーナリスト<br class="pc-show">古賀敬介の「WRCな日々」</a></li>'+
                              '<li><a href="/jp/blogcolumn/column2/" target="_self">レポーター（お）ねーさんの<br class="pc-show">モタスポコラム</a></li>'+
                              '<li><a href="/jp/kumakichi/" target="_self">くま吉ワールド</a></li>'+
                              '<li><a href="https://ameblo.jp/tsutomutojo/" target="_blank">エンジニア東條のブログ</a></li>'+
                            '</ul>'+
                          '</div>'+
                        '</nav>'+
                      '</div></div>';

    // CONTENTS NAV
    var pathArray = location.pathname.split("/");

    if( pathArray[2] === 'lexus-customer-racing' ){
        this.baseSrc += '<div id="contents-top-navigation">'+
                            '<div class="tpl__container">'+
                                '<ul class="ctn-kind-menu lexus-customer-racing-2018-menu">'+
                                    '<li>'+
                                        '<a class="sp-ctn-menu-trigger" href="#"><span></span><span></span><span></span></a>'+
                                        '<header class="lexus-customer-racing-2018">'+
                                            '<div class="header-inner">'+
                                                '<p class="logo"><img src="/pages/contents/jp/lexus-customer-racing/images/logo_lexus_f.png" alt="LEXUS F"></p>'+
                                                '<h1 class="title"><a href="/jp/lexus-customer-racing/">LEXUS CUSTOMER RACING</a></h1>'+
                                                '<div class="local-navi">'+
                                                    '<nav>'+
                                                    '   <ul class="ctn-menu">'+
                                                    '       <li class="menu1"><a class="hover-opacity2"  href="/jp/lexus-customer-racing/about/">RACE</a></li>'+
                                                    '       <li class="menu2"><a class="hover-opacity2"  href="/jp/lexus-customer-racing/car/">CAR</a></li>'+
                                                    '       <li class="menu3"><a class="hover-opacity2"  href="/jp/lexus-customer-racing/teamdriver/">TEAM &amp; DRIVER</a></li>'+
                                                    '       <li class="menu4"><a class="hover-opacity2"  href="/jp/lexus-customer-racing/special/">SPECIAL</a></li>'+
                                                    '       <li class="menu5"><a class="hover-opacity2"  href="/jp/lexus-customer-racing/news/">NEWS</a></li>'+
                                                    '       <li class="menu6"><a class="hover-opacity2"  href="/jp/lexus-customer-racing/report/">RACE REPORT</a></li>'+
                                                    '   </ul>'+
                                                    '</nav>'+
                                                '</div>'+
                                            '</div>'+
                                        '</header>'+
                                    '</li>'+
                                '</ul>'+
                            '</div>'+
                        '</div>';
    } else if(pathArray[3] === 'release') {

    } else {
        this.baseSrc += '<div id="contents-top-navigation">'+
            '<div class="tpl__container">'+
            '<ul class="ctn-kind-menu">'+
            '<li class="grid-panel-menu">'+
            '<div class="ctn-page-name js-header-scroll-height" data-import="page_name"></div>'+
            '<a class="sp-ctn-menu-trigger" href="#"><span></span><span></span><span></span></a>'+
            '<ul class="ctn-menu grid-panel-menu" data-import="submenu"></ul>'+
            '</li>'+
            '</ul>'+
            '</div>'+
            '</div>';
    }


    // SP
    this.baseSrc += '<div class="sp-global-menu-trigger-container">'+
                        '<div class="sp-gmt-block grid-panel-menu is-between">'+
                            '<div class="sp-gmt-block-left grid-panel-menu is-between">'+
                                '<a id="tgr-site-logo-sp" href="'+this.tpl.SUB.LOGO.URL+'" onclick="sc(\''+this.tpl.SUB.LOGO.SC+'\')"><img src="'+this.tpl.SUB.LOGO.SRC+'" alt="'+this.tpl.SUB.LOGO.NAME+'"></a>'+
                                // '<a class="tgr-search-sp modal-open"  data-target="search-form" href="#"><img src="/pages/contents/jp/tgr-asset/image/icon/search.svg" alt="検索"></a>'+
                            '</div>'+
                        '<div class="sp-global-menu-trigger-block-right">'+
                        // '<a id="sp-global-menu-trigger" href="#">MENU</a>'+
                        '<a id="sp-global-menu-trigger" href=""></a>'+
                    '</div>'+
                '</header>';

        $('#header').html(this.baseSrc);
        $('body').append('<script src="/pages/jpn/assets/js/lib.js"></script>');

    this.init();

};

window.TGR2018.HeaderTemplateGenerator.prototype = {
    init: function () {
        var src = '',
            sub = window.TGR2018.HEADER_TEMPLATE.SUB,
            src2 = '',
            information = sub.INFORMATION,
            informationLength = information.length,
            i = 0;

        for ( i = 0; i < informationLength; i++ ) {
            src2 += this.addInformationTemp(information,i);
        }

        $('#gh-information-menu').html(src2);
    },
    addInformationTemp: function(information,index){
        var src = '';
        src += '<li class="'+information[index].CLASS+'" data-target="'+information[index].DATA_TARGET+'">';
        src += '    <a href="'+information[index].URL+'" onclick="sc(\''+information[index].SC+'\')" target="'+information[index].TARGET+'">'+information[index].NAME+'</a>';
        if( this.subnav[information[index].DATA_TARGET] ) {
          src += this.subnav[information[index].DATA_TARGET];
        }
        src += '</li>';

        return src;
    },
};

window.TGR2018.SearchModalTemplateGenerator = function(){
    this.src =  '<script src="/pages/contents/include/common/js/mf/sug.js#sv=https://mf2ap003.marsflag.com/mf2/toyotagazooracing__ja_all__ja_all"></script>'+
        '<div id="search-form" class="modal-content">'+
        '<form action="/jp/search/" target="_self" name="searchform">'+
        '<div class="top-freeword_search top-layout__section01__right">'+
        '<div class="tjp2016-search_box type-freeword">'+
        '<div class="tjp2016-search_box__text"><input type="text" placeholder="フリーワード検索" class="tjp2016-text_input--freeword" name="q" id="MF_form_phrase" autocomplete="off" /></div>'+
        '<div class="tjp2016-search_box__bt"><button class="tjp2016-bt2--search--large">検索</button></div>'+
        '</div>'+
        '</div>'+
        '<input type="hidden" name="ie" value="utf8" />'+
        '</form>'+
        '</div>';

    this.init();
}
window.TGR2018.SearchModalTemplateGenerator.prototype = {
    init: function(){
        var that = this;
        $('body').append(this.src);

        $(this.src).ready(function(){
            that.addEvent();
        })

    },
    addEvent: function(){
        // 「.modal-open」をクリック
        $(document).on('click','.modal-open',function(e){
            e.preventDefault();

            // オーバーレイ用の要素を追加
            $('body').append('<div class="modal-overlay"></div>');
            // オーバーレイをフェードイン
            $('.modal-overlay').fadeIn('slow');

            // モーダルコンテンツのIDを取得
            var modal = '#' + $(this).attr('data-target');
            // モーダルコンテンツの表示位置を設定
            modalResize();
            // モーダルコンテンツフェードイン
            $(modal).fadeIn('slow');
            document.searchform.q.focus();
            // 「.modal-overlay」あるいは「.modal-close」をクリック
            $('.modal-overlay, .modal-close').off().click(function(){
                // モーダルコンテンツとオーバーレイをフェードアウト
                $(modal).fadeOut('slow');
                $('.modal-overlay').fadeOut('slow',function(){
                    // オーバーレイを削除
                    $('.modal-overlay').remove();
                });
            });

            // リサイズしたら表示位置を再取得
            $(window).on('resize', function(){
                modalResize();
            });

            // モーダルコンテンツの表示位置を設定する関数
            function modalResize(){
                // ウィンドウの横幅、高さを取得
                var w = $(window).width();
                var h = $(window).height();

                // モーダルコンテンツの表示位置を取得
                var x = (w - $(modal).outerWidth(true)) / 2;
                var y = (h - $(modal).outerHeight(true)) / 2;

                // モーダルコンテンツの表示位置を設定
                $(modal).css({'left': x + 'px','top': y + 'px'});
            }
        });
    }
};

window.TGR2018.HeaderSubNav = function(){
  this.currentNavID = null;
  this.navFlag = false;
  this.menuFlag = false;
  this.closeTimer = null;
  this.menuTimer = null;
  this.openTimer = null;
  this.navDelay = 100;
  this.menuDelay = 100;

  this.$menu = $('.gh-subnav-block');
  this.$trigger = $('.js-subnav');

  this.open = this.open.bind(this);
  this.close = this.close.bind(this);
  this.onNav = this.onNav.bind(this);
  this.offNav = this.offNav.bind(this);
  this.onMenu = this.onMenu.bind(this);
  this.offMenu = this.offMenu.bind(this);

  this.BREAKPOINT = 870;
  this.isSP = window.matchMedia('(max-width:'+this.BREAKPOINT+'px)').matches;

  this.$trigger.on('mouseenter', this.onNav);
  this.$trigger.on('mouseleave', this.offNav);
  this.$menu.on('mouseenter', this.onMenu);
  this.$menu.on('mouseleave', this.offMenu);

  var self = this;

  //URLパターンマッチ（グロナビのカレント表示）
  $.each(window.TGR2018.HEADER_TEMPLATE.SUB.INFORMATION, function(){
    var hierarchy = this.HIERARCHY;
    var dataTarget = this.DATA_TARGET;
    var isCurrent = false;

    if(!Array.isArray(hierarchy)){
      //配列でなければ処理を飛ばす
      return true;
    }

    $.each(hierarchy, function(){
      if ( location.pathname.indexOf(this) != -1 ) {
        isCurrent = true;
        return false;
      }
    });

    if(isCurrent) {
      $('#gh-information-menu > li[data-target='+dataTarget+']').addClass('is-current');
      return false;
    }
  });


  $('.js-subnav > a').on('click', function(e){
    //PCのときのみ、クリックでは開閉させずに、コンテンツトップに飛ぶ
    if( !$('html').hasClass('is-others') || self.isSP ) {
      e.preventDefault();
      if( self.isSP ){
        //スマホサイズの場合はアコーディオン開閉する
        $(this).parents('li').toggleClass('is-active');
        $(this).next('.gh-subnav-block').stop().slideToggle(200);
      } else {
        //タブレット横のときは、クリックで開閉する
        e.currentTarget = $(this).parents('li').eq(0);
        if( $(this).parents('li').hasClass('is-active') ) {
          self.offNav(e);
        } else {
          self.onNav(e);
        }
      }
    }
  });

  // リサイズしたら表示位置を再取得
  $(window).on('resize', function(){
    var oldMode = self.isSP;
    var currentMode = window.matchMedia('(max-width:'+self.BREAKPOINT+'px)').matches;
    if( oldMode !== currentMode ) {
      self.$menu.removeAttr('style');
      self.$menu.find('.gh-subnav-container').removeAttr('style');
      self.isSP = currentMode;
      $('.js-subnav, .gh-subnav-block').removeClass('is-active');
    }
  });
};

window.TGR2018.HeaderSubNav.prototype = {
  open : function(navID) {
    // 同じメニューならなにもしない
    if (navID === this.currentNavID) { return; }
    var self = this;
    var delay = 0;
    var globalH = $('#global-header .gh-main-header').height();
    this.$menu.css('top', globalH);

    this.$trigger
      .removeClass('is-active')
      .filter('[data-target=' + navID + ']')
      .addClass('is-active');

    this.$menu.filter('.is-active').not('#' + this.currentNavID).removeClass('is-active');

    this.killTween();

    if (this.currentNavID !== null) {
      TweenMax.to($('#' + this.currentNavID).find('.gh-subnav-container'), 0.3, {
        opacity: 0,
        ease : Power1.easeOut
      });
      TweenMax.to($('#' + this.currentNavID), 0.3, {
        height: 0,
        ease : Power1.easeOut,
        onComplete: function() {
          $('#' + this.currentNavID).removeClass('is-active');
        }
      });
      delay = 0.3;
    } else {
      this.$menu.css('height', 0);
    }

    this.currentNavID = navID;

    var $currentNav = $('#' + navID);
    $currentNav.addClass('is-active');
    $currentNav.find('.gh-subnav-container').css('opacity', 0);

    var menuH = $currentNav.find('.gh-subnav-container').outerHeight();
    TweenMax.to($currentNav, 0.3, {
      delay: delay,
      height: menuH,
      ease : Power1.easeOut
    });

    TweenMax.to($currentNav.find('.gh-subnav-container'), 0.2, {
      delay: delay + 0.3,
      opacity: 1,
      ease : Power1.easeOut
    });

  },

  close : function() {
    clearTimeout(this.menuTimer);
    var self = this;

    this.currentNavID = null;
    this.$trigger.removeClass('is-active');

    this.killTween();
    TweenMax.to(this.$menu.filter('.is-active').find('.gh-subnav-container'), 0.3, {
      opacity: 0,
      ease : Power1.easeOut
    });
    TweenMax.to(this.$menu.filter('.is-active'), 0.3, {
      height: 0,
      ease : Power1.easeOut,
      onComplete: function() {
        self.$menu.filter('.is-active').removeClass('is-active');
      }
    });
  },

  onNav : function(e) {
    if( this.isSP || (!$('html').hasClass('is-others') && e.type !== 'click') ) { return; }

    this.navFlag = true;
    var $target = $(e.currentTarget);
    var navID = $target.data('target');
    var self = this;

    clearTimeout(this.openTimer);
    clearTimeout(this.closeTimer);
    this.openTimer = setTimeout(function() {
      self.open(navID);
    }, 500);
  },

  offNav : function(e) {
    if( this.isSP ) { return; }

    this.navFlag = false;
    var $target = $(e.currentTarget);
    var index = parseInt($target.attr('data-nav-index'), 10);
    var self = this;

    clearTimeout(this.openTimer);
    self.closeTimer = setTimeout(function() {
      if (self.menuFlag === true) { return; }
      self.close();
    }, self.navDelay);
  },

  onMenu : function() {
    if( this.isSP ) { return; }

    this.menuFlag = true;
  },

  offMenu : function() {
    if( this.isSP ) { return; }

    var self = this;
    this.menuFlag = false;

    self.menuTimer = setTimeout(function() {
      if (self.navFlag === true) { return; }
      self.close();
    }, self.menuDelay);
  },

  killTween : function(){
    TweenMax.killChildTweensOf('.gh-subnav-block');
    TweenMax.killChildTweensOf('.gh-subnav-container');
  }
};


new TGR2018.HeaderTemplateGenerator();
new TGR2018.SearchModalTemplateGenerator();
new TGR2018.HeaderSubNav();
TGR2018.headerHide = true;
if(window.location.href.indexOf('/release/')>-1) { TGR2018.headerHide = false; }
if(window.location.href.indexOf('/toyotagazooracing.com/archive/')>-1) { TGR2018.headerHide = false; }
if(window.location.href.indexOf('/jp/search/')>-1) { TGR2018.headerHide = false; }
!function(e){function t(n){if(i[n])return i[n].exports;var o=i[n]={i:n,l:!1,exports:{}};return e[n].call(o.exports,o,o.exports,t),o.l=!0,o.exports}var i={};t.m=e,t.c=i,t.i=function(e){return e},t.d=function(e,i,n){t.o(e,i)||Object.defineProperty(e,i,{configurable:!1,enumerable:!0,get:n})},t.n=function(e){var i=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(i,"a",i),i},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p="",t(t.s=16)}([,,function(e,t,i){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,t){for(var i=0;i<t.length;i++){var n=t[i];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,i,n){return i&&e(t.prototype,i),n&&e(t,n),t}}(),r=function(){function e(){n(this,e),this.$header=$("#global-header"),this.$target=$(".sub-page-top-section")}return o(e,[{key:"init",value:function(e){this.$target=e||this.$target}},{key:"run",value:function(e){window.TGR2018.breakPoint<e?this.$target.css({"padding-top":this.$header.innerHeight()}):this._clear()}},{key:"_clear",value:function(){this.$target.css({"padding-top":""})}}]),e}();t.a=r},function(e,t,i){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,t){for(var i=0;i<t.length;i++){var n=t[i];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,i,n){return i&&e(t.prototype,i),n&&e(t,n),t}}(),r=function(){function e(){n(this,e),this.$others=$("#main,#global-footer"),this.$localNavTrigger=$(".js-local-navigation-trigger")}return o(e,[{key:"run",value:function(){var e=this;this.$localNavTrigger.children("a").on("click.GlobalNavigation",function(t){t.preventDefault();var i=$(t.currentTarget).parent("li");e._check(i)?e._close(i):e._open(i)}),$(document).on("click.GlobalNavigation","#main,#global-footer",function(t){e._check(e.$localNavTrigger)&&e._close(e.$localNavTrigger)})}},{key:"_check",value:function(e){return e.hasClass("is-local-menu-open")}},{key:"_open",value:function(e){this._close(e.siblings()),e.addClass("is-local-menu-open")}},{key:"_close",value:function(e){e.removeClass("is-local-menu-open")}},{key:"destroy",value:function(){this._close(this.$localNavTrigger),this.$localNavTrigger.children("a").off("click.GlobalNavigation"),this.$others.off("click.GlobalNavigation")}}]),e}();t.a=r},function(e,t,i){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,t){for(var i=0;i<t.length;i++){var n=t[i];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,i,n){return i&&e(t.prototype,i),n&&e(t,n),t}}(),r=function(){function e(){n(this,e),this.target=$("#global-header"),this.$headerScrollHeight=$(".js-header-scroll-height"),this.st=0,this.kind=$("[data-page-kind]").attr("data-page-kind"),this.$body=$("body")}return o(e,[{key:"action",value:function(e){if(this._checkFixGoToBtn(e),this._showHideSwitchGoToBtn(e),$(".ctn-menu>li").length){if($("#global-header").hasClass("is-menu-open")||$(".js-local-navigation-trigger").hasClass("is-local-menu-open"))return this.$body.removeClass("header-hide"),void(this.st=e);this._showHideSwitchHeader(e),this.st=e}}},{key:"_checkFixGoToBtn",value:function(e){this.point2<=e?$("#page-go-up").css({position:"absolute",bottom:this.point2Height}):$("#page-go-up").css({position:"",bottom:""})}},{key:"_showHideSwitchGoToBtn",value:function(e){
//jquery1.Xからjquery3.Xへの応急処置ここから
//日本語版のみreleaseディレクトリがカテゴリー配下の場合のみ（第2階層がreleaseの時のみ？）配下のページでthis.pointがjquery-1.10.2ではnullだったのがjquery-3.4.1ではundefinedになる症状の処置
var $dir = location.pathname.split("/");
var $dir2 = $dir[3];
if($dir2 === 'release'){this.point = null}
//jquery1.Xからjquery3.Xへの応急処置ここまで
e>=this.point?this.$body.addClass("is-top-show"):this.$body.removeClass("is-top-show")}},{key:"_showHideSwitchHeader",value:function(e){if(!TGR2018.headerHide){e>this.point&&e>this.st&&this.$body.addClass("header-hide"),(e<this.point||e<this.st)&&this.$body.removeClass("header-hide")}}},{key:"resize",value:function(){if(TGR2018.breakPoint<$(window).innerWidth()){var e=$(".gf-unit");this.point2=e.offset().top-$(window).innerHeight()+120,this.point2Height=e.innerHeight()-120}else{var t=$(".gf-unit-foot");this.point2=t.offset().top-$(window).innerHeight()+120,this.point2Height=t.innerHeight()-90}this.point=this.$headerScrollHeight.innerHeight();if (TGR2018.headerHide&&window.location.hash.length&&$(window.location.hash).length){this.$body.addClass("header-hide"),setTimeout(function(){TGR2018.headerHide=false},2000)}else{$(".ctn-menu>li").length&&(this.$body.removeClass("header-hide"),TGR2018.headerHide=false,this.point=this.$headerScrollHeight.innerHeight())}}}]),e}();t.a=r},,,,,,function(e,t,i){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,t){for(var i=0;i<t.length;i++){var n=t[i];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,i,n){return i&&e(t.prototype,i),n&&e(t,n),t}}(),r=function(){function e(){n(this,e),this.$others=$("#main,#global-footer"),this.$header=$("#global-header"),this.$menuTrigger=$("#sp-global-menu-trigger"),this.$ctnMenuTrigger=$(".sp-ctn-menu-trigger")}return o(e,[{key:"run",value:function(){var e=this;this.$menuTrigger.on("click.SpGlobalNavigation",function(t){t.preventDefault(),$(t.currentTarget),e._check(e.$header)?e._close(e.$header):e._open(e.$header)}),this.$others.on("click.SpGlobalNavigation",function(t){e._check(e.$header)&&e._close(e.$header)}),this.$ctnMenuTrigger.on("click.SpGlobalNavigation",function(t){t.preventDefault();var i=$(t.currentTarget).parent("li");e._check(i)?e._closeCtn(i):e._openCtn(i)})}},{key:"_check",value:function(e){return e.hasClass("is-menu-open")}},{key:"_open",value:function(e){$(".global-header-block").scrollTop(0),e.addClass("is-menu-open")}},{key:"_close",value:function(e){e.removeClass("is-menu-open")}},{key:"_openCtn",value:function(e){e.addClass("is-menu-open")}},{key:"_closeCtn",value:function(e){e.removeClass("is-menu-open")}},{key:"destroy",value:function(){this._close(this.$header),this._closeCtn(this.$ctnMenuTrigger.parent("li")),this.$menuTrigger.off("click.SpGlobalNavigation"),this.$others.off("click.SpGlobalNavigation"),this.$ctnMenuTrigger.off("click.SpGlobalNavigation")}}]),e}();t.a=r},,function(e,t,i){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,t){for(var i=0;i<t.length;i++){var n=t[i];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,i,n){return i&&e(t.prototype,i),n&&e(t,n),t}}(),r=function(){function e(){n(this,e),this.$target=$(".js-synchronize-hover-target"),this.$trigger=$(".js-synchronize-hover-trigger")}return o(e,[{key:"run",value:function(){var e=this;if(this.$target.length&&this.$trigger.length){for(var t=0;t<this.$trigger.length;t++)this._mouseEnterHandle($(".js-synchronize-hover-trigger").eq(t).find("li"),0,!1);this.$trigger.find("li").on({mouseenter:function(t){var i=$(t.currentTarget),n=i.index();e._mouseEnterHandle(i,n,!0)},mouseleave:function(){e._mouseLeaveHandle()}})}}},{key:"_mouseEnterHandle",value:function(e,t,i){var n=e.parents(".js-synchronize-hover-parent").find(this.$target),o=$(n.find("li")[t]);i?(n.addClass("is-hover"),o.addClass("is-opacity-active is-scale-active").siblings().removeClass("is-opacity-active is-scale-active")):o.addClass("is-opacity-active").siblings().removeClass("is-opacity-active")}},{key:"_mouseLeaveHandle",value:function(){this.$target.removeClass("is-hover").find("li").removeClass("is-scale-active")}},{key:"_clear",value:function(){}}]),e}();t.a=r},,function(e,t,i){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var o=function(){function e(e,t){for(var i=0;i<t.length;i++){var n=t[i];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,i,n){return i&&e(t.prototype,i),n&&e(t,n),t}}(),r=function(){function e(){n(this,e),this.tablet=!1,this.mobile=!1,this.android=!1,this.iphone=!1,this.getBrowser(),this._init(),this._addDevice()}return o(e,[{key:"_init",value:function(){var e=window.navigator.userAgent.toLowerCase();this.tablet=-1!==e.indexOf("windows")&&-1!==e.indexOf("touch")&&-1===e.indexOf("tablet pc")||-1!==e.indexOf("ipad")||-1!==e.indexOf("android")&&-1===e.indexOf("mobile")||-1!==e.indexOf("firefox")&&-1!==e.indexOf("tablet")||-1!==e.indexOf("kindle")||-1!==e.indexOf("silk")||-1!==e.indexOf("playbook"),this.mobile=-1!==e.indexOf("windows")&&-1!==e.indexOf("phone")||-1!==e.indexOf("iphone")||-1!==e.indexOf("ipod")||-1!==e.indexOf("android")&&-1!==e.indexOf("mobile")||-1!==e.indexOf("firefox")&&-1!==e.indexOf("mobile")||-1!==e.indexOf("blackberry"),this.android=-1!==e.indexOf("android")&&-1!==e.indexOf("mobile"),this.iphone=-1!==e.indexOf("iphone")||-1!==e.indexOf("ipod")}},{key:"getBrowser",value:function(){var e=(window.navigator.userAgent.toLowerCase(),window.navigator.appVersion.toLowerCase(),null),t=null,i=window.navigator.userAgent.toLowerCase();i.match(/(msie|MSIE)/)||i.match(/(T|t)rident/)?(e=!0,t=i.match(/((msie|MSIE)\s|rv:)([\d\.]+)/)[3],t=parseInt(t)):e=!1,e&&$("body").addClass("is-ie")}},{key:"_addDevice",value:function(){var e=document.querySelector("html");this.tablet?e.setAttribute("class","is-tablet"):this.mobile?e.setAttribute("class","is-mobile"):this.android?e.setAttribute("class","is-android"):this.iphone?e.setAttribute("class","is-iphone"):e.setAttribute("class","is-others")}},{key:"viewPort",value:function(e,t){this[e]&&document.querySelector('meta[name="viewport"]').setAttribute("content","width="+t+",user-scalable=no")}}]),e}();t.a=r},,function(e,t,i){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var n=i(14),o=i(3),r=i(10),a=i(4),s=i(2),l=i(12);window.TGR2018=window.TGR2018||{},TGR2018.$w=$(window),TGR2018.wInnerWidth=TGR2018.$w.innerWidth(),TGR2018.PRODCT=!0,TGR2018.PATH="",TGR2018.PRODCT||(TGR2018.PATH="https://toyotagazooracing.com/"),TGR2018.$directry_url_raw=location.pathname,TGR2018.$directry_url_split=TGR2018.$directry_url_raw.split("/"),TGR2018.$file_name=TGR2018.$directry_url_split.pop(),TGR2018.$directry_url=TGR2018.$directry_url_raw.replace(new RegExp(TGR2018.$file_name,"g"),""),TGR2018.$now_url=location.href.split("/"),TGR2018.$category_url=TGR2018.$directry_url_split[2],TGR2018.$pagetype_url=TGR2018.$directry_url_split[3],void 0!==TGR2018.$category_url&&null!==TGR2018.$category_url||(TGR2018.$category_url="index"),TGR2018.ua=new n.a,TGR2018.MOBILE=TGR2018.ua.mobile,TGR2018.TABLET=TGR2018.ua.tablet,TGR2018.OTHER=!TGR2018.MOBILE&&!TGR2018.TABLET,TGR2018.breakPoint=870,TGR2018.gNav=new o.a,TGR2018.spGNav=new r.a,TGR2018.header=new a.a,TGR2018.contentGetSpace=new s.a,TGR2018.synchronizeHover=new l.a,TGR2018.checkWindowWidth=function(e){return TGR2018.breakPoint<e},TGR2018.isPc=TGR2018.checkWindowWidth(TGR2018.wInnerWidth),TGR2018.isCurrentPc=TGR2018.checkWindowWidth(TGR2018.wInnerWidth),$(window).on("resize",function(){TGR2018.isPc=TGR2018.checkWindowWidth(TGR2018.wInnerWidth=$(window).innerWidth())})}]);

setTimeout(setHashScroll(),2000)
function setHashScroll(){
    var myHash = window.location.hash;
    if(myHash.length) {
        var margin = $('#global-header .gh-main-header:visible').outerHeight() + $('#contents-top-navigation:visible').outerHeight() + 30;
        $('body,html').stop().scrollTop(0);
        $(window).on('load', function(){
            var target = $(myHash);
            if(target.length) {
                var targettop = target.offset().top;
                var dur = Math.abs(targettop - (document.body.scrollTop || document.documentElement.scrollTop));
                if(dur > 800) {
                    dur = 800;
                }
                $('html,body').stop().animate({scrollTop:targettop-margin}, {duration:dur,complete:function(){}});
            } else {
                $('body').removeClass('header-hide');
            }
        });
    }
}
