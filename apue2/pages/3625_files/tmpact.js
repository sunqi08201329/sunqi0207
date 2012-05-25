/*加载日常活动标签*/
//添加到[id='header']上面
(function(){
	var show = 1; //是否展示，0是不展示，1是展示，2只在首页展示，3只在词条页展示
	//信息分两组，1组是首页，2组是词条页，如果show=1，就只按照1来展示
	var linkSrc1 = 'http://img.baidu.com/img/baike/usercenter/fair2.png?me=kubi';
	//var linkSrc1 = 'http://img.baidu.com/img/baike/usercenter/fair.png?me=kubi';//图片的地址
	var linkHref1 = 'http://baike.baidu.com/view/2010.htm';//图片的链接
	var linkText1 = '纪念胡适逝世50周年';//鼠标滑过信息
	var isLink1 = false; //是否是连接，true的话linkHref1和linkText1必须给
	var isFlash1 = false;
	var flashSrc1 = 'http://img.baidu.com/img/baike/usercenter/celebration/2012/sleep.swf';
	var beginDate = '03/21/2012';
	
	var linkSrc2 = 'http://baike.baidu.com/cms/s/banner/bowuguan06.png';//图片的地址 
	var linkHref2 = 'http://baike.baidu.com/museum/';//图片的链接
	var linkText2 = '全新上线 抢鲜体验';//鼠标滑过信息
	var isLink2 = true;
	var isFlash2 = false;
	addSheet('#userbar{z-index:100 !important;} #encourage_tip_wrapper{z-index:19}');

	var wrap = baidu.dom.query('ul.nav.f14')[0];
	var viewFlag = (document.body.id == 'view');
	//默认的设置，都是连接
	function defaultSet(src, href, text){
		//链接的话，大小是238*60
		var link = document.createElement('a');
		link.href = href;
		link.target = '_blank';
		link.hideFocus = true;
		link.innerHTML = text;
		link.onclick = function(){
			nslog(location.href, 3626);
		}
		link.title = text;
		fixZIndex();
		//link.style.cssText = 'position:absolute;top:-60px;right:0;width:238px;height:60px;outline:0;font-size:0;text-indent:-999em;background:url('+ src +') no-repeat 0 0;';
		link.style.cssText = 'position:absolute;top:-100px;right:-46px;width:400px;height:100px;outline:0;font-size:0;text-indent:-999em;background:url('+ src +') no-repeat 0 0';
		wrap.appendChild(link);
	}
	//flash页面
	function flashSet(src){
		var link = document.createElement('div');
		link.id = 'bk-push';
		var title = document.title;
		baidu.swf.create({
			id:'flash',
			url:src,
			width:240,
			height:60,
			wmode: 'transparent',
			allowscriptaccess: 'always'
		}, link);
		fixZIndex();
		link.style.cssText = 'position:absolute;top:-60px;right:0;width:240px;height:60px;';
		setTimeout(function(){wrap.appendChild(link);},300);
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
					var curTitle = document.title;
					if(curTitle.indexOf('#') != -1 && curTitle != title){
						clearInterval(timer);
						document.title = title;
					}
				}, 100);	
			} catch (exp){}
		}
	}
	//独特的首页#_$，只需要一个图片地址。
	function singleSet(src){
		//普通的话，大小是400*100，注意阿姨6/7下的margin不折叠，所以高度要长一些
		var ca = document.createElement('div');
		fixZIndex();
		ca.style.cssText = 'position:absolute;top:-100px;right:-46px;width:400px;height:100px;outline:0;font-size:0;text-indent:-999em;background:url('+ src +') no-repeat 0 0;';
		wrap.appendChild(ca);
	}

	function fixZIndex(){
		//设置一下head的z-index，确保在#userbar和#header最下面，目前#userbar的z-index是10
		if(!viewFlag){//首页和view页搜索框名字不一样，首页只设置按钮的parentNode即可
			var foreground = baidu.dom.query('input[value=搜索词条]')[0];
			foreground.style.zIndex = 9;
			foreground.style.position = 'relative';
			var helpBtn = baidu.dom.next(foreground);
			helpBtn.style.zIndex = 9;
			helpBtn.style.position = 'relative';
			var setBtn = baidu.dom.next(helpBtn);
			setBtn.style.zIndex = 9;
			setBtn.style.position = 'relative';
		}
		else{
			var foreground = baidu.dom.query('input[value=进入词条],input[value=搜索词条]');
			foreground[0].style.zIndex = 9;
			foreground[0].style.position = 'relative';
			foreground[1].style.zIndex = 9;
			foreground[1].style.position = 'relative';
			var help = baidu.g('help');
			help.style.zIndex = 9;
			help.style.position = 'relative';
		}
	}

	 function addSheet(css){
        if(!-[1,]){
            css = css.replace(/opacity:\s*(\d?\.\d+)/g,function($,$1){
                $1 = parseFloat($1) * 100;
                if($1 < 0 || $1 > 100)
                    return "";
                return "filter:alpha(opacity="+ $1 +");"
            });
        }
        css += "\n";//增加末尾的换行符，方便在firebug下的查看。
        var doc = document, head = doc.getElementsByTagName("head")[0],
        styles = head.getElementsByTagName("style"),style,media;
        if(styles.length == 0){//如果不存在style元素则创建
            if(doc.createStyleSheet){    //ie
                doc.createStyleSheet();
            }else{
                style = doc.createElement('style');//w3c
                style.setAttribute("type", "text/css");
                head.insertBefore(style,null)
            }
        }
        style = styles[0];
        media = style.getAttribute("media");
        if(media === null && !/screen/i.test(media) ){
            style.setAttribute("media","all");
        }
        if(style.styleSheet){    //ie
            style.styleSheet.cssText += css;//添加新的内部样式
        }else{
            style.appendChild(doc.createTextNode(css))
        }
    }

	function generatePage(src, href, text, isLink, isFlash){
		/*if(isFlash){
			flashSet(src);
		}
		else{
			isLink ? defaultSet(src, href, text) : singleSet(src);
		}*/
		isLink ? defaultSet(src, href, text) : singleSet(src);
	}
	
	baidu.page.loadJsFile('/cms/s/6years/egg.js?t='+Math.random());
	
	if(wrap){
		if(1 == show){
			viewFlag ? generatePage(linkSrc2, linkHref2, linkText2, isLink2, isFlash2) : generatePage(linkSrc1, linkHref1, linkText1, isLink1, isFlash1);
			return;
		}
		
		if(2 == show && !viewFlag){
			/*if(isFlash1 && new Date - Date.parse(beginDate) > 0){
				flashSet(flashSrc1);
				return;
			}*/
			generatePage(linkSrc1, linkHref1, linkText1, isLink1, isFlash1);
			return;
		}

		if(3 == show && viewFlag){
			generatePage(linkSrc2, linkHref2, linkText2, isLink2, isFlash2);
		}
	}
})();