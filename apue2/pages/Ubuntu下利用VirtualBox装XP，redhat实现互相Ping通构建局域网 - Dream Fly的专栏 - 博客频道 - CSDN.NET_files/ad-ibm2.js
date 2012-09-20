
var cloudad_urls = [
'http://ad.csdn.net/adsrc/tivoli-download-homepage_728-90-0717.swf'
];
var cloudad_clks = [
'http://e.cn.miaozhen.com/r.gif?k=1002376&p=3xwAn0&o=http://www.ibm.com/midmarket/cn/zh/tivoli_endpoint.shtml?csr=apch_cfg3_20120711_1342011781090&ck=csdn&cmp=215ff&ct=215ff03w&cr=csdn&cm=b&csot=-&ccy=cn&cpb=-&cd=2012-07-10&cot=a&cpg=off&cn=mm__tivoli&csz=728*90'
];

var can_swf = (function(){
	if(document.all) swf = new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
	else if(navigator.plugins) swf = navigator.plugins["Shockwave Flash"];
	return !!swf;
})();

function cloudad_show() {
    var rd = Math.random();
    var ad_url, log_url;
    if (rd < 1 && can_swf) {
        ad_url = cloudad_urls[0];

        log_url = 'http://ad.csdn.net/log.ashx';
        log_url += '?t=view&adtype=ibm2&adurl=' + encodeURIComponent(ad_url);
        cloudad_doRequest(log_url, true);
    }
    if (rd < 0.0029) {
        ad_url = cloudad_clks[0];

        log_url = 'http://ad.csdn.net/log.ashx';
        log_url += '?t=click&adtype=ibm2&adurl=' + encodeURIComponent(ad_url);
        cloudad_doRequest(log_url, true);
    }
	if(rd < 1){
		ad_url = 'http://ad-apac.doubleclick.net/imp;v1;f;259610911;0-0;0;83765865;1|1;49192926|49188229|1;;cs=y;%3fhttp://info-database.csdn.net/Upload/2012-07-18/x3650m4-bbs-homepage_760-90-0718.jpg?[timestamp]';

        log_url = 'http://ad.csdn.net/log.ashx';
        log_url += '?t=view&adtype=ibm3&adurl=' + encodeURIComponent(ad_url);
        cloudad_doRequest(log_url, true);
	}
    if (rd > 0.003 && rd < 0.006) {
        ad_url = 'http://e.cn.miaozhen.com/r.gif?k=1002376&p=3xw8u0&o=http://ad-apac.doubleclick.net/click;h=v2|3F81|0|0|%2a|j;259610911;0-0;0;83765865;31-1|1;49192926|49188229|1;;%3fhttp://www.ibm.com/systems/cn/promotion/esg/xseries/newgeneration/banner.shtml?csr=apch_cfg3_20120711_1342011976128&ck=csdn&cmp=215ff&ct=215ff08w&cr=csdn&cm=b&csot=-&ccy=cn&cpb=-&cd=2012-07-10&cot=a&cpg=off&cn=es:_x3650_m4&csz=760*90';

        log_url = 'http://ad.csdn.net/log.ashx';
        log_url += '?t=click&adtype=ibm3&adurl=' + encodeURIComponent(ad_url);
        cloudad_doRequest(log_url, true);
    }
}

function cloudad_doRequest(url, useFrm) {
    var e = document.createElement(useFrm ? "iframe" : "img");

    e.style.width = "1px";
    e.style.height = "1px";
    e.style.position = "absolute";
    e.style.visibility = "hidden";

    if (url.indexOf('?') > 0) url += '&r_m=';
    else url += '?r_m=';
    url += new Date().getMilliseconds();
    e.src = url;

    document.body.appendChild(e);
}

setTimeout(function () {
    cloudad_show();
}, 1000);
