//********************
//功能：前端推送方式的功能实现脚本（供与素材无关的推送方式使用）
//作者：leexs
//时间：2012-4-27
//********************

var url1 = "http://s.vancl.com/search?source=";
var url2 = "http://union.vancl.com/MediaPosting/Search/SearchWord?s=";
var url3 = "http://union.vancl.com/MediaPosting/Search/SearchShow?s=";
var url4 = "http://union.vancl.com/MediaPosting/Record/Show?s=";

//#region 异步请求页面
var asyncRequest = function (requestUrl) {
    var cvancl = document.createElement('script');
    cvancl.src = requestUrl;
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(cvancl, s);
}
//#endregion

//引用此页面即记录展示量
if (sourcesuninfo == null || sourcesuninfo == undefined || sourcesuninfo == "") {
    asyncRequest(url3 + source + "&t=20&f=" + escape(document.location.href));
}
else {
    asyncRequest(url4 + source + "&son=" + sourcesuninfo + "&refer=" + escape(document.location.href));
}

//#region 搜索框功能
var singleSearch = function () {
    var txt = document.getElementById("vanclSearchTxt").value;

    if (txt != null && txt != "") {
        //查询窗口
        var surl = url1 + source + "&sourcesuninfo=" + sourcesuninfo + "&k=" + escape(txt);
        window.open(surl);

        //搜索词记录
        surl = url2 + source + "&t=20&k=" + escape(txt) + "&f=" + escape(document.location.href);
        asyncRequest(surl);
    }
}
//#endregion
