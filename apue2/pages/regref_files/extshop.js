//
// 正则表达式分析类
//
// Copyright 2006 (c) RegExLab.com
//
// Author: 史寿伟 ( Sswater Shi )
//         sswater@gmail.com
//
// 本代码中所使用的复杂正则表达式，均在 Regex Match Tracer 协助下编写完成。
//
// Download Regex Match Tracer:
// http://www.regexlab.com/mtracer/
//
//

function NewArray()
{
    var arr = new Array();
    arr.count = 0;
    return arr;
}

function AppendToArray(arr, el)
{
    arr[arr.count ++] = el;
}

RegExp.prototype.exec2 = function exec2( stxt )
{
    var _lI = this.lastIndex;
    this.lastIndex = 0;

    var match = null;

    if( _lI < stxt.length )
    {
        match = this.exec( stxt.substr( _lI ) );

        if( match != null )
        {
            match.input      = stxt;
            match.index     += _lI;
            match.lastIndex  = match.index + match[0].length;

            this. lastIndex  = match.lastIndex;
        }
    }

    return match;
}

function ColorEl(pos, len, clr)
{
    this.m_pos = pos;
    this.m_len = len;
    this.m_clr = clr;
}

function ElementCompare( el1, el2 )
{
    if( el1.m_pos != el2.m_pos )
        return (el1.m_pos - el2.m_pos);
    else
        return (el2.m_len - el1.m_len);
}

function CheckBracket( pattern, match, leftb, clrtable, clr, ppre )
{
    if( pattern.substr( match.index, leftb.length ) == leftb )
    {
        AppendToArray(clrtable, new ColorEl(match.index, leftb.length, clr));

        if( pattern.charAt(match.lastIndex - 1) == ')' )
        {
            AppendToArray(clrtable, new ColorEl(match.lastIndex - 1, 1, clr));
        }

        ppre.lastIndex = match.index + leftb.length;

        return true;
    }
    else
    {
        return false;
    }
}

function CheckNamed( pattern, match, leftb, clrtable, clr, ppre, endname )
{
    if( pattern.substr( match.index, leftb.length ) == leftb )
    {
        var leftlen  = pattern.substring(match.index + leftb.length, match.lastIndex).search(endname);
        var matchlen = match.lastIndex - match.index;

        if( leftlen >= 0 )
            leftlen += leftb.length + 1;
        else
            leftlen = matchlen;

        AppendToArray(clrtable, new ColorEl(match.index, leftlen, clr));

        if( matchlen > leftlen && pattern.charAt(match.lastIndex - 1) == ')' )
        {
            AppendToArray(clrtable, new ColorEl(match.lastIndex - 1, 1, clr));
        }

        ppre.lastIndex = match.index + leftlen;

        return true;
    }
    else
    {
        return false;
    }
}

function CheckSpecial( pattern, match, leftb, clrtable, clr, ppre )
{
    if( pattern.substr( match.index, leftb.length ) == leftb )
    {
        AppendToArray(clrtable, new ColorEl(match.index, match.lastIndex - match.index, clr));

        ppre.lastIndex = match.lastIndex;

        return true;
    }
    else
    {
        return false;
    }
}

function CheckConditional( pattern, match, leftb, clrtable, clr, ppre )
{
    if( pattern.substr( match.index, leftb.length ) == leftb )
    {
        AppendToArray(clrtable, new ColorEl(match.index, 2, clr));

        if( pattern.charAt(match.lastIndex - 1) == ')' )
        {
            AppendToArray(clrtable, new ColorEl(match.lastIndex - 1, 1, clr));
        }

        ppre.lastIndex = match.index + 2;

        return true;
    }
    else
    {
        return false;
    }
}

function CheckCommon( subpattern, offset, match, checker, clrtable, clr )
{
    if( subpattern.substring(match.index, match.lastIndex).search(checker) == 0 )
    {
        AppendToArray(clrtable, new ColorEl(match.index + offset, match.lastIndex - match.index, clr));

        return true;
    }
    else
    {
        return false;
    }
}

function CheckQuote( subpattern, offset, match, clrtable, clr )
{
    if( subpattern.substring(match.index, match.lastIndex).search( /^\\[QLU]/ ) == 0 )
    {
        AppendToArray(clrtable, new ColorEl(match.index + offset, 2, clr));

        if( subpattern.substr(match.lastIndex - 2, 2) == "\\E" )
        {
            AppendToArray(clrtable, new ColorEl(match.lastIndex - 2 + offset, 2, clr));
        }

        return true;
    }
    else
    {
        return false;
    }
}

function CommonColor( subpattern, offset, clrtable, isext )
{
    var cpre = null, tmre = null;

    if( isext )
    {
        if( CommonColor.s_cpre_ex == null )
            CommonColor.s_cpre_ex = new RegExp("[^\\[\\(\\)\\#\\\\?+*{^$.|]+|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n)?)*\\]?|\\\\(?:.|\\n)?)*\\]?|\\(\\?\\#[^)]*\\)?|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\[kg](?:<[^>]*>?|\'[^\']*\'?)|\\\\\\d{1,3}|[?+*^$.|]|\\{[^}]*\\}?|\\\\x(?:[\\dA-Fa-f]{1,2}|\\{[^}]*\\}?)|\\\\u(?:[\\dA-Fa-f]{1,4}|\\{[^}]*\\}?)|\\\\(?:.|\\n)?", "g");

        cpre = CommonColor.s_cpre_ex;
        tmre = /^(\(\?\#|\#)/;
    }
    else
    {
        if( CommonColor.s_cpre_cm == null )
            CommonColor.s_cpre_cm = new RegExp("[^\\[\\(\\)\\\\?+*{^$.|]+|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n)?)*\\]?|\\\\(?:.|\\n)?)*\\]?|\\(\\?\\#[^)]*\\)?|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\[kg](?:<[^>]*>?|\'[^\']*\'?)|\\\\\\d{1,3}|[?+*^$.|]|\\{[^}]*\\}?|\\\\x(?:[\\dA-Fa-f]{1,2}|\\{[^}]*\\}?)|\\\\u(?:[\\dA-Fa-f]{1,4}|\\{[^}]*\\}?)|\\\\(?:.|\\n)?", "g");

        cpre = CommonColor.s_cpre_cm;
        tmre = /^\(\?\#/;
    }

    cpre.lastIndex = 0;

    var match = cpre.exec2( subpattern );

    while( match != null )
    {
        if(
            CheckCommon(subpattern, offset, match, /^(\[|\.|\\[sSdDwW])/  , clrtable, "#900050") ||
            CheckQuote (subpattern, offset, match,                          clrtable, "#008000") ||
            CheckCommon(subpattern, offset, match, /^[?+*{]/              , clrtable, "#e07000") ||
            CheckCommon(subpattern, offset, match, /^\|/                  , clrtable, "#5050ff") ||
            CheckCommon(subpattern, offset, match, tmre                   , clrtable, "#008000") ||
            CheckCommon(subpattern, offset, match, /^(\^|\$|\\[AZbkg\d])/ , clrtable, "#ff00ff")
        );

        cpre.lastIndex = match.lastIndex;
        match = cpre.exec2( subpattern );
    }
}

function PatternColor( pattern, clrtable, isext )
{
    var ppre = null;

    if( isext )
    {
        if( PatternColor.s_ppre_ex == null )
            PatternColor.s_ppre_ex = new RegExp("((?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))+)|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:[^\\[\\(\\)\\#\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\#.*?(?:\\r\\n?|\\n\\r?|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$)", "g");

        ppre = PatternColor.s_ppre_ex;
    }
    else
    {
        if( PatternColor.s_ppre_cm == null )
            PatternColor.s_ppre_cm = new RegExp("((?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))+)|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:(?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))|\\((?:[^\\[\\(\\)\\\\]|\\[(?:[^\\[\\]\\\\]|\\[(?:[^\\[\\]\\\\]|\\\\(?:.|\\n|$))*(?:\\]|$)|\\\\(?:.|\\n|$))*(?:\\]|$)|\\(\\?\\#[^)]*(?:\\)|$)|\\\\[QLU](?:(?!\\\\E)(?:.|\\n))*(?:\\\\E)?|\\\\(?:.|\\n|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$))*(?:\\)|$)", "g");

        ppre = PatternColor.s_ppre_cm;
    }

    ppre.lastIndex = 0;

    var match = ppre.exec2( pattern );

    while( match != null )
    {
        if( match[1] == null || match[1] == "" )
        {
            if(
                CheckBracket(pattern, match, "(?=" , clrtable, "#999999", ppre) ||
                CheckBracket(pattern, match, "(?!" , clrtable, "#999999", ppre) ||
                CheckBracket(pattern, match, "(?<=", clrtable, "#999999", ppre) ||
                CheckBracket(pattern, match, "(?<!", clrtable, "#999999", ppre) ||
                CheckBracket(pattern, match, "(?>" , clrtable, "#999999", ppre) ||
                CheckBracket(pattern, match, "(?:" , clrtable, "#999999", ppre) ||


                CheckNamed(pattern, match, "(?<" , clrtable, "#5050ff", ppre, ">") ||
                CheckNamed(pattern, match, "(?'" , clrtable, "#5050ff", ppre, "'") ||
                CheckNamed(pattern, match, "(?P<", clrtable, "#5050ff", ppre, ">") || // named


                CheckSpecial(pattern, match, "(?R", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?1", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?2", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?3", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?4", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?5", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?6", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?7", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?8", clrtable, "#ff00ff", ppre) ||
                CheckSpecial(pattern, match, "(?9", clrtable, "#ff00ff", ppre) || // recursive


                CheckConditional(pattern, match, "(?(", clrtable, "#ff00ff", ppre) || // conditional


                CheckNamed(pattern, match, "(?" , clrtable, "#999999", ppre, ":") || // mode modifier


                CheckBracket(pattern, match, "(", clrtable, "#5050ff", ppre)
            );
        }
        else
        {
            CommonColor(pattern.substring(match.index, match.lastIndex), match.index, clrtable, isext);
            ppre.lastIndex = match.lastIndex;
        }

        match = ppre.exec2( pattern );
    }

    clrtable.sort( ElementCompare );
}

function ExportColorHTML(pattern, clrtable)
{
    var html = new Array(), lastp = 0;

    html[html.length] = "<font color=#000000>";

    for(var i=0; i<clrtable.count; i++)
    {
        if(clrtable[i].m_pos > lastp)
        {
            html[html.length] = formatstr( pattern.substring(lastp, clrtable[i].m_pos) );
        }

        html[html.length] = "<font color=" + clrtable[i].m_clr + ">" + formatstr( pattern.substr(clrtable[i].m_pos, clrtable[i].m_len) ) + "</font>";

        lastp = clrtable[i].m_pos + clrtable[i].m_len;
    }

    if(pattern.length > lastp)
    {
        html[html.length] = formatstr( pattern.substr(lastp) );
    }
    
    html[html.length] = "</font>";

    return html.join("");
}
