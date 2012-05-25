

/***************************************************************************
 * Description:实现百科活动彩蛋
 *
 * Author  : liuzhen01
 * Language: javascript
 * Date    : 2011-03-23
 ***************************************************************************/
// 需要baidu.more.ns包的支持
(function() {
	baidu.more.ns('bk.activity.sf');
	var EGG_REQ_URL = '/api/sixyear?';
	var EGG_SWF_URL = '/cms/s/6years/eggs/';
	var FIX_POSITION = false;//固定位置，屏幕正中间

	var template = '<div class="popbox">\
		<a target="_self" href="javascript:void(0);" class="close" id="sixyearPopCloseBtn">关闭</a>\
		<div class="popcon">\
			<p style="font-family:tahoma"><span class="gift"></span>#{msg}</p>\
			<p class="link"><a hidefocus="true" target="_blank"  href="/cms/s/6years/surprise.html">查看我的周年活动积分</a></p>\
			<a href="javascript:void(0);" class="btn" id="sixyearPopConfirmBtn">确定</a>\
		</div>\
	</div>';
	bk.activity.egg = function(options) {
		this.eggDom = null;
		this._dialog = null;
		this.id = options.id;
		this.type = 1; //彩蛋的类型
		baidu.extend(this, options);
	};
	baidu.lang.inherits(bk.activity.egg, baidu.lang.Class);
	baidu.extend(bk.activity.egg.prototype, {
		show: function() {
			this.eggDom.style.display = 'block';
		},
		hide: function() {
			this.eggDom.style.display = 'none';
		},
		close: function(flag) {
			if (this.eggDom) {//这次再次恶心一把
				this.eggDom.parentNode.removeChild(this.eggDom);
			}
			else{
				var wrap = baidu.g('sixyearwrap');
				if(wrap){
					wrap.parentNode.removeChild(wrap);
				}
			}
			this.dispatchEvent('onClose', {
				flag: flag
			});
		}
	});

	bk.activity.sf.egg = baidu.lang.createClass(function(options) {
		bk.activity.egg.call(this, options);
	}, {
		superClass: bk.activity.egg
	}).extend({
		/**
		 * 构造彩蛋主体，根据id值调用不同的彩蛋来显示
		 *
		 */
		build: function(container) {
			if (!this.eggDom) {
				var eggDom = document.createElement('div');
				eggDom.id = 'sixyearwrap';
				eggDom.style.cssText = 'width:250px;height:260px;position:absolute;z-index:'+(location.pathname.indexOf('/cms/s/6years')===0 ? 999:99);
				
				var title = document.title;
				var swfHTML = baidu.swf.createHTML({
					url: EGG_SWF_URL+this.id+'.swf?r='+Math.random(),
					width: 250,
					height: 260,
					wmode: 'transparent',
					allowscriptaccess: 'always'
				});
				eggDom.innerHTML = swfHTML;

				var doc = document;
				var title = doc.title;
				
				if(baidu.browser.ie){
					try{
					var timer = null;
					var count = 0 //记录次数，如果1分钟了还木改变，就停止
					var totalCount = 600;
					timer = setInterval(function(){
						if(count++ > totalCount){
							clearInterval(timer);
							return;
						}
						var curTitle = doc.title;
						if(curTitle.indexOf('#') != -1 && curTitle != title){
							clearInterval(timer);
							doc.title = title;
						}
					}, 100);	
					}catch(expp){}
				}
				var context = getEggContext(FIX_POSITION);
				container = context.container;
				delete context.container;
				baidu.dom.setStyles(eggDom, context);
					container.appendChild(eggDom);
				
				this.eggDom = eggDom;
				if (location.pathname.indexOf('/cms/s/zhuanti-2011pandian/index.html') == 0) {
						var div = baidu.dom.query('.egg div')[0];
						div && baidu.dom.setStyle(div, 'background-color', 'transparent');
				}
			}

			function getEggContext(fixPos){
				//如果在首页和词条页
				var path = location.pathname;
				if((path == '/' || path.indexOf('/view/') === 0) && !fixPos){
					var ct = baidu.dom.query('ul.nav.f14')[0];
					var userInfo = baidu.g('userInfoDiv');
					if(path.indexOf('/view/') === 0 && baidu.browser.ie <= 7){//坑爹
						//ct.style.zIndex = 8;
						//ct.style.position = 'relative';
					}
					return {top:-90,right:30,container:path == '/' ? ct : userInfo};
				}
				else{
					var viewWidth = baidu.page.getViewWidth();
					return {top:200,left:(viewWidth-250)/2, container:document.body};
				}
			}
		},
		userGet: function() {
			var me = this;
			baidu.ajax.post(EGG_REQ_URL, baidu.url.jsonToQuery({
				t: Math.random(),
				action: 'userGetEgg',
				type:this.id
			}), function(xhr) {
				var result = baidu.json.parse(xhr.responseText);
				if (result.status) {
					me.onGetSuccess(result.score);
				} else {
					me.onGetFail(result.errorCode);
				}
			});
		},
		//获取彩蛋成功
		onGetSuccess: function(score) {
			var content = bk.activity.sf.egg.generateContent(this,true, score);
			var dialog = this.getDialog({
				content: content
			});
			dialog.open();
			this.dispatchEvent('onUserGetSuccess', {
				score: score
			});
			this.close();
			nslog(location.href, 5307);
		},
		onGetFail: function(code) {
			this.close();
			switch (parseInt(code)) {
			case 0:
				var content = bk.activity.sf.egg.generateContent(this, false);
				var dialog = this.getDialog({
					content: content
				});
				dialog.open();
				break;
			case 1:
				alert('对不起，当前非该彩蛋领取时间哦');
				break;
			case 2:
				alert('出错了哦');
				break;
			}
			this.dispatchEvent('onUserGetFail', {
				errorCode: code
			});
		},
		getDialog: function(ops) {
			var title = ops.title || '恭喜您成功找到一枚彩蛋';
			var eggId = this.id;
			if (!this._dialog) {
				this._dialog = new bk.Dialog({
					titleText: title,
					titlebar:false,
					buttonbar:false,
					autoRender: true,
					width: 345,
					height: 175,
					contentText: ops.content,
					modal: true,
					buttonbar: false,
					classPrefix: 'bk-sixyear-dialog',
					onopen: function() {
						var self = this;
						var btns = baidu.dom.query('#sixyearPopCloseBtn,#sixyearPopConfirmBtn');
						baidu.each(btns, function(btn){
							baidu.on(btn, 'click', function(){
								self.close();
							});
						});
					}
				});
			} else {
				this._dialog.titleText = ops.title || defaultTitle;
				this._dialog.contentText = ops.content;
				this._dialog.update();
			}
			return this._dialog;
		}
	});
	baidu.extend(bk.activity.sf.egg, {
		//彩蛋信息
		generateContent: function(egg, succ, score) {
			var obj = {};
			if(succ){
				var index = baidu.number.pad(parseInt(score)/10, 2);
				obj.msg = '恭喜您收集到这枚彩蛋，获得'+ 10*index +'个活动积分。';
			}
			else{
				if(egg.id == 6){//如果是最后一个蛋
					obj.msg = '厉害，所有的彩蛋您都收集完毕。感谢您的参与。';
				}
				else{
					obj.msg = '哇哦，这枚彩蛋您已经收集了。请关注后续活动。';
				}
				
			}
			//先这么恶心着吧，加几十就是第几个彩蛋
			return baidu.string.format(template, obj);
		}
	});
}());
/**
 * 百科春节活动
 */
baidu.more.ns('bk.activity');
bk.activity.act = {
	DEBUG: false,
	pending : false,//是否在请求，防止彩蛋被多次点击
	GET_EGG_INFO_URL: '/api/sixyear',
	AUTOPLAY_KEY: 'sixyearegg',
	UNLOGIN_RATIO:.001,//未登录用户命中彩蛋的概率
	DATE_RANGES : [//每个彩蛋展现的时间
		['2012-04-19', '2012-04-24'],
		['2012-04-25', '2012-04-30'],
		['2012-05-01', '2012-05-06'],
		['2012-05-07', '2012-05-12'],
		['2012-05-13', '2012-05-18'],
		['2012-05-19', '2012-05-25']
	],
	eggInfo: [],
	requestEggInfo: function(callback) {
		var me = this;
		baidu.ajax.post(this.GET_EGG_INFO_URL, baidu.url.jsonToQuery({
			action: 'getEggInfo'
		}), function(xhr) {
			var result = baidu.json.parse(xhr.responseText);
			if (result.status === true) {
				var info = [];
				for (var i = 0, len = result.eggs.length; i < len; i++) {
					info.push({
						id: i + 1,
						got: result.eggs[i]
					});
				}
				me.eggInfo = info;
				if (baidu.lang.isFunction(callback)) {
					callback(result.eggs);
				}
				bk.event.fire('bk.event.egginfo.request', {
					egg: result.eggs
				});
			}
		});
	},
	getEggInfo: function() {
		//获取彩蛋是否在当前页面可以展示
		function inPage(id){
			var pathes = [
				'/',//首页
				'/view/',//词条页
				'/cms/s/6years'//活动页面
			];
			var path = location.pathname;
			if(path == pathes[0]){
				return true;
			}
			
			switch(eggId){
				case 1:
				case 3:
				case 5:
				case 6:
					return path.indexOf(pathes[1]) !== -1;
				case 2:
				case 4:
					return path.indexOf(pathes[1]) !== -1 || path.indexOf(pathes[2]) !== -1;
			}
		}
		var eggId = null;
		var today = new Date;
		var dateRanges = this.DATE_RANGES;
		// 按现在的时间来决定显示哪个彩蛋
		for (var i = 0, len = dateRanges.length; i < len; i++) {
			var start = dateRanges[i][0];
			var end = dateRanges[i][1] + ' 23:59:59';
			if (today >= baidu.date.parse(start) && today < baidu.date.parse(end)) {
				eggId = i+1;
				break;
			}
		}

		if (eggId === null)
		{
			return false;
		}
		else if(!inPage(eggId)){
			return false;
		}

		return {
			id:eggId,
			got:this.eggInfo[eggId-1].got
		};
	},
	complete: function(eggId) {
		if(this.pending){
			return;
		}
		var self = this;//解决异步读写
		this.pending = true;
		setTimeout(function(){
			self.pending = false;
		}, 1500);
		this.onEggClick(eggId);
	},
	showComplete:function(eggId) {//这个地方的实现太挫了
		var egg = new bk.activity.sf.egg({id:eggId});
		var content = bk.activity.sf.egg.generateContent(egg, false);
		var dialog = egg.getDialog({
			content: content
		});
		dialog.open();
	},
	showError: function() {},
	checkCookie: function(eggId) {
		if (baidu.cookie.get(this.AUTOPLAY_KEY)) {//如果用户之前点击了
			if(this.egg.got){//已经拿过
				this.showComplete(eggId);
			}
			else{
				var egg = new bk.activity.sf.egg({
					id: eggId,
					onUserGetSuccess: function(score) {
						egg.got = 1;
					}
				});
				egg.userGet();
			}
			baidu.cookie.remove(this.AUTOPLAY_KEY);
		}
		else{
			if(!this.eggInfo[eggId-1].got){
				this.showEgg({id:eggId});
				nslog(location.href, 5308);
			}
		}
	},
	onEggClick: function(eggId) {
		var me = this;
		nslog(location.href, 5306);
		// 未登录
		if(!this.user) {
			userlogin(function() {
				baidu.cookie.set(me.AUTOPLAY_KEY, "1");
				window.location.href = window.location.href.replace(/#.*$/g, "");
			});
			return;
		}
		else if(!me.eggInfo[eggId-1].got){//已登录蛋未拿
			var egg = new bk.activity.sf.egg({
				id: eggId,
				onUserGetSuccess: function() {
					egg.got = 1;
				}
			});
			egg.userGet();
		}
		else{
			this.showComplete(eggId);
		}
	},
	showEgg: function(egg) {
		if (!egg) {
			return;
		}
		this.egg = new bk.activity.sf.egg({
			id: egg.id
		});
		this.egg.build();
	},
	close:function(){
		this.egg && this.egg.close();
	},
	init: function() {
		var me = this;
		function userloginCheck(yes, no) {
			//未提供curUser的页面看title.php
			var oldUserlogin = false;
			var frame = baidu.dom.query('iframe[src*=/list-php/dispose/title.php]');
			if(frame.length>0){
				frame = frame[0];
				frame.contentWindow.flag = oldUserlogin;
			}
				if (window.curUser || oldUserlogin) {
					yes();
				} else {
					no();
				}
			}
		userloginCheck(function() {
			me.user = true;
			me.requestEggInfo(function() {
				var egg = me.getEggInfo();
				me.egg = egg;
				if (egg) {
					me.checkCookie(egg.id);
				}
			});
		}, function() {
			me.user = false;
			me.eggInfo = [
				{
					id: 1,
					got: false
				}, {
					id: 2,
					got: false
				}, {
					id: 3,
					got: false
				}, {
					id: 4,
					got: false
				}, {
					id: 5,
					got: false
				}, {
					id: 6,
					got: false
				}
			];
			var egg = me.getEggInfo();
			if (egg && Math.random() <= me.UNLOGIN_RATIO) {
				me.showEgg(egg);
			}
		});
	},
	//获取参加人数
	getJoinCount: function(callback) {
		var params = {
			action: 'getTotal'
		};
		if (this.DEBUG) {
			params['r'] = 1;
		}
		baidu.ajax.post(this.GET_EGG_INFO_URL, baidu.url.jsonToQuery(params), function(xhr) {
			var result = baidu.json.parse(xhr.responseText);
			if (callback) {
				callback(result.count);
			}
		});
	},
	//弹出感谢信
	popThanks: function() {
		var letterDialog = new bk.Dialog({
			titlebar: false,
			autoRender: true,
			autoDispose: true,
			width: 550,
			height: 610,
			contentText: '<div style="position:relative;"><a id="thanksPopClose" href="javascript:;" onclick="" style="position: absolute;top: 22px;right: 97px;height: 20px;width: 20px;background:url(about:blank);"></a><img src="http://img.baidu.com/img/baike/usercenter/celebration/2012/letter.png"/></div>',
			modal: true,
			buttonbar: false,
			shadow: false,
			classPrefix: '',
			tplContent: "<div id='#{id}' class='#{class}' style='overflow:hidden; position:relative'>" + "<div class='#{class}-shade'></div><div class='dialog-content-inner'>#{content}</div></div>",
			onopen: function() {
				baidu.on('thanksPopClose', 'click', function() {
					letterDialog.close();
				});
			}
		});
		letterDialog.open();
	}
};
baidu.dom.ready(function() {
	baidu.page.loadCssFile('/cms/s/6years/egg.css?t'+Math.random());//先加载样式
	setTimeout(function() {
		bk.activity.act.init();
	}, 800);
});
