//
// 常用函数
//
// Copyright 2005 (c) RegExLab.com
//
// Author: 史寿伟 ( Sswater Shi )
//         sswater@gmail.com
//

//
// 文本 HTML Encode by sswater
//
function formatstr( str )
{
    if( str == null ) return "";

    var str2 = str;

    str2 = str2.replace( /&/g   , "&amp;"    );
    str2 = str2.replace( /</g   , "&lt;"    );
    str2 = str2.replace( />/g   , "&gt;"    );
    str2 = str2.replace( /\r\n?|\n\r?/g , "<br>"  );

    str2 = str2.replace( /\t/g, "&nbsp; &nbsp; " );
    str2 = str2.replace( /\x20\x20/g, "&nbsp; " );
    str2 = str2.replace( /\x20\x20/g, " &nbsp;" );
    str2 = str2.replace( /(^|<br>)\x20/g, "$1&nbsp;");

    return str2;
}

//
// 得到 text
//
function gettext( html )
{
    if( gettext.spaces == null ) gettext.spaces = new RegExp("\\s+", "g");
    if( gettext.stags  == null ) gettext.stags  = new RegExp("<(/?)\\s*\\b([\\w\\-:.]+(?!\\w))(?:\"[^\"]*\"?|\'[^\']*\'?|/(?!\\>)|[^/>])*/?>?", "g");
    if( gettext.blank2 == null ) gettext.blank2 = new RegExp("^\\x20|\\x20$", "g");
    if( gettext.brs    == null ) gettext.brs    = new RegExp("<p>\\x20?|<br>\\x20?", "ig");
    if( gettext.tags   == null ) gettext.tags   = new RegExp("</?[\\w\\-:.]+>?", "g");
    if( gettext.nbsps  == null ) gettext.nbsps  = new RegExp("&nbsp\\b;?", "ig");
    if( gettext.lts    == null ) gettext.lts    = new RegExp("&lt\\b;?", "ig");
    if( gettext.gts    == null ) gettext.gts    = new RegExp("&gt\\b;?", "ig");
    if( gettext.quots  == null ) gettext.quots  = new RegExp("&quot\\b;?", "ig");

    if( gettext.amps   == null ) gettext.amps   = new RegExp("&amp\\b;?", "ig");

    var text = html;

    text = text.replace( gettext.spaces, " " );
    text = text.replace( gettext.stags , "<$1$2>" );
    text = text.replace( gettext.blank2, "" );
    text = text.replace( gettext.brs   , "\n" );
    text = text.replace( gettext.tags  , "" );
    text = text.replace( gettext.nbsps , " " );
    text = text.replace( gettext.lts   , "<" );
    text = text.replace( gettext.gts   , ">" );
    text = text.replace( gettext.quots , "\"" );

    text = text.replace( gettext.amps  , "&" );

    return text;
}

//
// 要处理 '+', '_' 的 escape
//
function escape_plus( string )
{
    string = new String(string);
    var result = new Array()

    for(var i=0; i<string.length; i++)
    {
        var ch = string.charAt(i);

        if( (ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') )
            result[result.length] = ch;
        else
        {
            var cd = string.charCodeAt(i);
            var cc = "0000" + new Number(string.charCodeAt(i)).toString(16).toUpperCase();

            if( cd >= 128 )
                result[result.length] = "%u" + cc.substr(cc.length - 4);
            else
                result[result.length] = "%"  + cc.substr(cc.length - 2);
        }
    }

    return result.join("");
}

//
// 处理 %XX 格式和 %uXXXX
//
function unescape_plus( str )
{
    var re = /\+|%[0-9A-Fa-f]{1,2}|%u[0-9A-Fa-f]{1,4}/i;
    var result = new Array();
    var m = null;
    
    while( (m = re.exec(str)) != null )
    {
        if(m.index > 0)
            result[result.length] = str.substring(0, m.index);

        if(str.charAt(m.index) == '+')
            result[result.length] = " ";
        else
        {
            var subs = null;
            if(str.charAt(m.index+1) == 'u' || str.charAt(m.index+1) == 'U')
                subs = str.substr(m.index+2, m[0].length-2);
            else
                subs = str.substr(m.index+1, m[0].length-1);
            result[result.length] = String.fromCharCode( parseInt(subs, 16) )
        }

        str = str.substr(m.index + m[0].length);
        re.lastIndex = 0;
    }

    result[result.length] = str;

    return result.join("");
}

function getInnerText( el )
{
    var itext = el.innerText;
    
    if( itext != null )
    {
        return itext;
    }
    else
    {
        return gettext( el.innerHTML );
/*
        var range = el.ownerDocument.createRange(); 
        range.selectNodeContents( el ); 
        return range.toString();
*/
    }
}

function setInnerText( el, itext )
{
    el.innerHTML = formatstr( itext );
}

function close_ggad_box(i)
{
    var ggad_box = document.getElementById("ggad_box_" + i);
    if( ggad_box != null ) ggad_box.style.display = "none"; else alert("null");
}
