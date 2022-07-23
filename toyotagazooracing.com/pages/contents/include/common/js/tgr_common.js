/* jshint unused:false */
/* global tidHost */
/***************************************************************************************************
 * リンク先URL管理
 **************************************************************************************************/
var tgrCommon = {};

(function () {
var menuAnchorObject = {
	"YouTube"								:{"href":"https://www.youtube.com/c/TOYOTAGAZOORacingJPchannel", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:etc:youtube"},
	"Facebook"								:{"href":"https://www.facebook.com/TOYOTAGAZOORacing", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:etc:facebook"},
	"Twitter"								:{"href":"https://twitter.com/TOYOTA_GR", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:etc:twitter"},
	"RSS"									:{"href":"/pages/contents/jp/top/rss.xml", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:snsbtn:rss"},
	"ニュース"								:{"href":"/jp/news/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:etc:news"},
	"最新のニュース一覧"					:{"href":"/jp/news/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:etc:news"},
	"カレンダー"							:{"href":"/jp/calendar/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:etc:calendar"},
	"カレンダー一覧"						:{"href":"/jp/calendar/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:etc:calendar"},
	"プレスリリース"						:{"href":"/jp/pressrelease/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:etc:release"},
	"プレスリリース一覧"					:{"href":"/jp/pressrelease/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:etc:release"},

	"OUR STORY"								:{"href":"/jp/our-story/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:ourstory:top"},
	"THE WORLD IS ONE FUTURE"				:{"href":"/pages/special/theworldisone/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:theworldisone"},
	"5大陸走破プロジェクト"					:{"href":"/pages/special/fivecontinentsdrive/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:five"},
	"TNGA"									:{"href":"/pages/special/tnga/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:tnga"},
	"モータースポーツへの挑戦"				:{"href":"/pages/special/challenge/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:challenge"},
	"AKIO'S DRIVE"							:{"href":"/pages/special/akiosdrive/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:akiosdrive"},
	"なんだよ、GAZOOって。"					:{"href":"/pages/special/gallery/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:gallery"},
	"TAKERU SATOH MEETS GAZOO"				:{"href":"/pages/special/meetsgazoo/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:meetsgazoo"},
	"風の惑星"								:{"href":"/pages/special/kazenowakusei/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:kazenowakusei"},
	"VS SAMURAI 羅兎薔薇"					:{"href":"/pages/special/latvala/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:special:latvala"},

	"ABOUT"									:{"href":"/jp/about/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:about:top"},
	"TOYOTA GAZOO Racingについて"			:{"href":"/jp/about/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:about:tgr"},

	"モータースポーツ"						:{"href":"/jp/motorsports/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:top"},
	"モータースポーツ トップ"				:{"href":"/jp/motorsports/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:top"},
	"モータースポーツ活動一覧"				:{"href":"/jp/motorsports/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:activity"},
	"レース"								:{"href":"/jp/motorsports/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:race"},
	"WEC"									:{"href":"/jp/wec/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:wec"},
	"SUPER GT"								:{"href":"/jp/supergt/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:supergt"},
	"ニュルブルクリンク24時間レース"		:{"href":"/jp/nurburgring/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:nur"},
	"WRC"									:{"href":"/jp/wrc/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:wrc"},
	"ダカールラリー"						:{"href":"http://www.toyota-body.co.jp/dakar/pc/season2018/index.html", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:motorsports:dakar"},
	"全日本ラリー"							:{"href":"/jp/jrc/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:jrca"},
	"SUPER FORMULA"							:{"href":"/jp/superformula/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:superformula"},
	"F3/F4"									:{"href":"/jp/juniorformula/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:f3f4"},
	"86/BRZ Race"							:{"href":"/jp/86brz/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:86brz"},
	"Vitz Race"								:{"href":"/jp/vitz/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:netzcup"},
	"ラリーチャレンジ"						:{"href":"/jp/rallychallenge/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:trdrally"},
	"スーパー耐久アーカイブ"				:{"href":"/jp/supertaikyu/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:supertaikyu"},
	"NASCAR"								:{"href":"/jp/nascar/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:nascar"},
	"LEXUS CUSTOMER RACING"					:{"href":"/jp/lexus-customer-racing/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:lcr"},
	"IMSA"									:{"href":"/jp/imsa/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:imsa"},
	"WOMAN"									:{"href":"/jp/woman/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:woman"},
	"F1アーカイブ"							:{"href":"/archive/ms/jp/F1archive/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:motorsports:f1"},
	"ドライバー情報"						:{"href":"/jp/motorsports/driver/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:driver"},
	"T.D.P."								:{"href":"/jp/tdp/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:tdp"},
	"ラリーチャレンジプログラム"			:{"href":"/jp/challengeprogram_rally/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:challenge"},
	"観戦チケット購入ガイド"				:{"href":"/jp/motorsports/ticket/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:ticket"},
	"テレビ/ラジオ（番組表）"				:{"href":"/jp/motorsports/tvschedule/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:motorsports:guide"},

	"カーラインナップ"						:{"href":"/jp/carlineup/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:carlineup:top"},
	"カーラインナップ トップ"				:{"href":"/jp/carlineup/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:carlineup:top"},
	"GRMN/G'sとは"							:{"href":"/jp/carlineup/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:carlineup:grmngs"},
	"TOYOTA 86"								:{"href":"/jp/86", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:toyota86"},
	"GRMN"									:{"href":"/pages/grmn/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grmn"},
	"G's"									:{"href":"/pages/gs/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:gs"},

	"GR 86"									:{"href":"/jp/gr/gr86/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:gr86"},
	"GR Vitz"								:{"href":"/jp/gr/grvitz/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grvitz"},
	"GR SPORT PRIUS PHV"					:{"href":"/jp/gr/grspriusphv/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportpriusphv"},
	"GR SPORT AQUA"							:{"href":"/jp/gr/grsaqua/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportaqua"},
	"GR SPORT PRIUS α"						:{"href":"/jp/gr/grspriusalpha/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportpriusalpha"},
	"GR SPORT MARK X"						:{"href":"/jp/gr/grsmarkx/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportmarkx"},
	"GR SPORT HARRIER"						:{"href":"/jp/gr/grsharrier/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportharrier"},
	"GR SPORT NOAH"							:{"href":"/jp/gr/grsnoah/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportnoah"},
	"GR SPORT VOXY"							:{"href":"/jp/gr/grsvoxy/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportvoxy"},
	"GR SPORT Vitz"							:{"href":"/jp/gr/grsvitz/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grsportvitz"},
	"GRMN Vitz"								:{"href":"/pages/grmn/vitz/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:grmnvitz"},
	"YARIS GRMN"							:{"href":"/pages/grmn/yaris/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:yarisgrmn"},
	"GR Super Sport Concept"				:{"href":"/jp/gr/concept/ssc/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:concept:ssc"},
	"GR Supra Racing Concept"				:{"href":"/jp/gr/concept/supra/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:concept:supra"},
	"TOYOTA SPORTS 800 CONCEPT"								:{"href":"/jp/gr/concept/yotahachi/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:carlineup:concept:yotahachi"},

	"イベント"								:{"href":"/jp/event/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:top"},
	"イベント トップ"						:{"href":"/jp/event/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:top"},
	"TOYOTA GAZOO Racing Driving experience":{"href":"/jp/drivingexperience/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:drivingexperience"},
	"サーキットを走ろう！"					:{"href":"/jp/experience/wakudoki/circuit.html", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:circuit"},
	"スポーツドライビングレッスン"			:{"href":"/jp/experience/wakudoki/sportsdriving.html", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:sportsdriving"},
	"フルブレーキ／スラローム体験"			:{"href":"/jp/experience/wakudoki/fullbrake.html", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:fullbrake"},
	"TOYOTA GAZOO Racing FESTIVAL"			:{"href":"/jp/tgrf/2017/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:tgrf"},
	"TOYOTA GAZOO Racing PARK"				:{"href":"/jp/tgrp/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:tgrp"},
	"LGDA夏祭り"							:{"href":"/jp/supergt/lgda/index.html", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:lgdasummer"},
	"モータースポーツジャパン"				:{"href":"/jp/event/msj/2017/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:msj2017"},
	"東京オートサロン"						:{"href":"/jp/eventexhibition/tokyoautosalon/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:tokyoautosalon"},
	"大阪オートメッセ"						:{"href":"/jp/eventexhibition/osakaautomesse/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:osakaautomesse"},
	"名古屋オートトレンド"					:{"href":"/jp/eventexhibition/nagoyaautotrend/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:event:nagoyaautotrend"},
	"モーターショー"						:{"href":"http://www.toyota.co.jp/jpn/events/motorshow/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:event:motorshow"},
	"トヨタ会館ミュージアム"				:{"href":"http://www.toyota.co.jp/jp/about_toyota/facility/toyota_kaikan/index.html", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:event:museum"},
	"MEGA WEB" 								:{"href":"http://www.megaweb.gr.jp/area/csc/gr.html", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:event:megaweb"},

	"ムービー/フォト"						:{"href":"/jp/gallery/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:movie:top"},

	"エンターテイメント"					:{"href":"/jp/entertainment/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:top"},
	"エンターテイメント トップ"				:{"href":"/jp/entertainment/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:top"},
	"くま吉ワールド"						:{"href":"/jp/kumakichi/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:kumakichi"},
	"レーシングドライバー木下隆之コラム"	:{"href":"/jp/blogcolumn/column/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:kinoshita"},
	"GAZOO Lady"							:{"href":"/jp/glady/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:glady"},
	"Number × TOYOTA GAZOO Racing"			:{"href":"/jp/community/number/", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:number"},
	"壁紙カレンダー"						:{"href":"/jp/gallery/wallpaper-calendar.html", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:entertainment:calendar"},
	"ドライバー モリゾウのBLOG"				:{"href":"http://gazoo.com/my/sites/0001452260/Driver/default.aspx", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:entertainment:morizo"},
	"(お)ねーさんのブログ"					:{"href":"http://ameblo.jp/gazooracing-nesan/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:entertainment:nesan"},
	"エンジニア 東條のブログ"				:{"href":"http://gazoo.com/my/sites/0001452434/GazooRacing12/default.aspx", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:entertainment:tojo"},
	"TeamLandCruiser"						:{"href":"http://gazoo.com/my/sites/0001452528/tlc/default.aspx", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:entertainment:tlc"},
	"ノヴェル三重 VitzRace レポート"		:{"href":"http://gazoo.com/my/sites/0001468332/novelmie/default.aspx", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:entertainment:novel;"},
	"ブログ一覧"							:{"href":"/jp/entertainment/#blogs", "id":"", "css":"", "target":"", "sc":"gazooracing:gras:newgnav:community:blogs"},

	"公式グッズ"							:{"href":"http://shop.gazoo.com/shop/c/c1006/", "id":"", "css":"", "target":"_blank", "sc":"gazooracing:gras:newgnav:goods:top"},

	"GRアーカイブ"							:{"href":"/jp/archive/", "id":"", "css":"", "target":"", "sc":""},
	"アーカイブ"							:{"href":"/jp/archive/", "id":"", "css":"", "target":"", "sc":""},
	"ご利用に関して"						:{"href":"/jp/attribute/", "id":"", "css":"", "target":"", "sc":""},
	"プライバシーポリシー"					:{"href":"http://gazoo.com/privacypolicy/Pages/index.aspx", "id":"", "css":"", "target":"_blank", "sc":""},
	"利用規約"								:{"href":"http://gazoo.com/siterule/rules/Pages/index.aspx", "id":"", "css":"", "target":"_blank", "sc":""},
	"お問合せ"								:{"href":"http://gazoo.com/help/contact/Pages/index.aspx", "id":"", "css":"", "target":"_blank", "sc":""},
	"Global Site"							:{"href":"//toyotagazooracing.com/\?direct=global", "id":"", "css":"", "target":"_blank", "sc":""},
	"グローバルサイト"						:{"href":"//toyotagazooracing.com/\?direct=global", "id":"", "css":"", "target":"_blank", "sc":""},
};

/***************************************************************************************************
 * TGRメニュー <a>タグ生成
 **************************************************************************************************/
tgrCommon.headerAnchorHtml = function (name) {
	return menuAnchorHtml(name, true);
};
tgrCommon.footerAnchorHtml = function (name) {
	return menuAnchorHtml(name, false);
};
function menuAnchorHtml(name, scFlg) {
	var aObj = menuAnchorObject[name];
	if(aObj === undefined) {
		aObj = {};
	}
	var $anchor = $("<a>").attr("href", aObj.href).html(name);

	if (aObj.id) {
		$anchor.attr("id", aObj.id);
	}
	if (aObj.css) {
		$anchor.addClass(aObj.css);
	}
	if (aObj.target) {
		$anchor.attr("target", aObj.target);
	}
	if (scFlg && aObj.sc) {
		$anchor.on("click", function() {
			sc(aObj.sc);
		});
	}
	return $anchor;
}

/***************************************************************************************************
 * URL置換（HASHタグ・別パラメータ）
 **************************************************************************************************/
tgrCommon.replaceQuery = function (repUrl, addParam) {
	if(repUrl === "" || addParam === ""){
		return repUrl;
	}
	if(repUrl.indexOf("#") != -1){
		addParam += "#" + repUrl.split("#")[1];
		repUrl = repUrl.split("#")[0];
	}
	return (repUrl.indexOf("?") != -1) ? repUrl+"&"+addParam : repUrl+"?"+addParam ;
}

/**************************************************************************************************/

})();


/***************************************************************************************************
 * 210706 GA Click
 **************************************************************************************************/
function sc(contentsID){
  window.dataLayer = window.dataLayer||[];
  window.dataLayer.push({
    "event": "SCcustomlink",
    "SCcustomlink": "ex-"+contentsID
  });
}