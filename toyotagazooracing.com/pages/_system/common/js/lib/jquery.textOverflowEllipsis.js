(function($) {
	$.fn.textOverflowEllipsis = function(config) {
		var defaults = {
			resize: false,
			numOfCharactersToReduce : 1,
			suffix: '…'
		};

		var options = $.extend(defaults, config);

		// 比較用オブジェクトの取得
		function getWorker($target) {
			var worker = $target.clone();
			worker.css({
				display : 'block',
				position : 'absolute',
				overflow : 'visible',
				visibility : 'hidden',
				height : 'auto'
			}).css('max-height','');

			$target.after(worker);

			return worker;
		}

		var TextOverflowEllipsis = {
			init : function($target) {
				// オリジナルの文章を取得・保持する
				var html = $target.data('data-original');
				if (! html) {
					html = $target.html();
					$target.data('data-original', html);
				}
			},
			execute : function($target, $worker) {
				// var html = $target.data('data-original');
				var html = $target.html();
 
				// 指定した高さになるまで、1文字ずつ消去していく
				var maxHeight = $target.height();
				$worker.width($target.width()).html(html);
				while((html.length > 0) && ($worker.height() > maxHeight)) {
					html = html.substr(0, html.length - options.numOfCharactersToReduce);
					$worker.html(html + options.suffix);
				}

				// 文章を入れ替えて、複製した要素を削除する
				$target.html($worker.html());
			}
		};

		var $worker = getWorker(this.first());
		var result = this.each(function(index) {
			var $target = $(this);

			TextOverflowEllipsis.init($target);

			TextOverflowEllipsis.execute($target ,$worker);

			if (options.resize) {
				// ウィンドウリサイズに追従する
				var timerId = null;
				$(window).resize(function() {
					if (timerId) {
						clearTimeout(timerId);
					}

					timerId = setTimeout(function() {
						TextOverflowEllipsis.execute($target);
					}, 100);
				});
			}
		});

		$worker.remove();
		return result;
	};
})(jQuery);
