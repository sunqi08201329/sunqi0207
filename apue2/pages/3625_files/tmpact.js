/*�����ճ����ǩ*/
//��ӵ�[id='header']����
(function(){
	var show = 1; //�Ƿ�չʾ��0�ǲ�չʾ��1��չʾ��2ֻ����ҳչʾ��3ֻ�ڴ���ҳչʾ
	//��Ϣ�����飬1������ҳ��2���Ǵ���ҳ�����show=1����ֻ����1��չʾ
	var linkSrc1 = 'http://img.baidu.com/img/baike/usercenter/fair2.png?me=kubi';
	//var linkSrc1 = 'http://img.baidu.com/img/baike/usercenter/fair.png?me=kubi';//ͼƬ�ĵ�ַ
	var linkHref1 = 'http://baike.baidu.com/view/2010.htm';//ͼƬ������
	var linkText1 = '�����������50����';//��껬����Ϣ
	var isLink1 = false; //�Ƿ������ӣ�true�Ļ�linkHref1��linkText1�����
	var isFlash1 = false;
	var flashSrc1 = 'http://img.baidu.com/img/baike/usercenter/celebration/2012/sleep.swf';
	var beginDate = '03/21/2012';
	
	var linkSrc2 = 'http://baike.baidu.com/cms/s/banner/bowuguan06.png';//ͼƬ�ĵ�ַ 
	var linkHref2 = 'http://baike.baidu.com/museum/';//ͼƬ������
	var linkText2 = 'ȫ������ ��������';//��껬����Ϣ
	var isLink2 = true;
	var isFlash2 = false;
	addSheet('#userbar{z-index:100 !important;} #encourage_tip_wrapper{z-index:19}');

	var wrap = baidu.dom.query('ul.nav.f14')[0];
	var viewFlag = (document.body.id == 'view');
	//Ĭ�ϵ����ã���������
	function defaultSet(src, href, text){
		//���ӵĻ�����С��238*60
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
	//flashҳ��
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
				var count = 0 //��¼���������1�����˻�ľ�ı䣬��ֹͣ
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
	//���ص���ҳ#_$��ֻ��Ҫһ��ͼƬ��ַ��
	function singleSet(src){
		//��ͨ�Ļ�����С��400*100��ע�Ⱒ��6/7�µ�margin���۵������Ը߶�Ҫ��һЩ
		var ca = document.createElement('div');
		fixZIndex();
		ca.style.cssText = 'position:absolute;top:-100px;right:-46px;width:400px;height:100px;outline:0;font-size:0;text-indent:-999em;background:url('+ src +') no-repeat 0 0;';
		wrap.appendChild(ca);
	}

	function fixZIndex(){
		//����һ��head��z-index��ȷ����#userbar��#header�����棬Ŀǰ#userbar��z-index��10
		if(!viewFlag){//��ҳ��viewҳ���������ֲ�һ������ҳֻ���ð�ť��parentNode����
			var foreground = baidu.dom.query('input[value=��������]')[0];
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
			var foreground = baidu.dom.query('input[value=�������],input[value=��������]');
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
        css += "\n";//����ĩβ�Ļ��з���������firebug�µĲ鿴��
        var doc = document, head = doc.getElementsByTagName("head")[0],
        styles = head.getElementsByTagName("style"),style,media;
        if(styles.length == 0){//���������styleԪ���򴴽�
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
            style.styleSheet.cssText += css;//����µ��ڲ���ʽ
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