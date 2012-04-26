//
// Copyright 2006 (c) RegExLab.com
//
// Author: 史寿伟 ( Sswater Shi )
//         sswater@gmail.com
//
//

//
// 对单个元素进行“按正则表达式语法”着色
//
function regex_pattern_colorize( el, isext )
{
    var table   = NewArray();
    var pattern = getInnerText( el );

    pattern = pattern.replace( /\r\n?|\n\r?/g , "\n" );

    try
    {
        PatternColor(pattern, table, isext);

        el.innerHTML = ExportColorHTML(pattern, table);

        return true;
    }
    catch (e)
    {
        return false;
    }
}

//
// 对单个元素进行“去掉颜色”
//
function un_colorize( el )
{
    setInnerText( el, getInnerText( el ).replace( /\r\n?|\n\r?/g , "\n" ) );
}

//
// 从 isext table 中获取是否 ext
//
function getIsext( isexttable, index )
{
    if( isexttable == null || isexttable.length == null || isexttable.length == 0 )
        return false;
    else
        return isexttable[ index % isexttable.length ];
}

//
// 使用 isext table 进行对多个元素进行着色
//
function regex_pattern_colorize_all( tagname, isexttable )
{
    var regex_patterns = document.getElementsByName( tagname );

    if( regex_patterns == null || regex_patterns.length == 0 )
    {
        return false;
    }

    if( regex_patterns.length == null )
    {
        return regex_pattern_colorize( regex_patterns, getIsext( isexttable, 0 ) );
    }
    else
    {
        for(var i=0; i<regex_patterns.length; i++)
        {
            if( ! regex_pattern_colorize( regex_patterns[i], getIsext( isexttable, i ) ) ) return false;
        }

        return true;
    }
}

//
// 对多个元素进行“去掉颜色”
//
function un_colorize_all( tagname )
{
    var regex_patterns = document.getElementsByName( tagname );
    
    if( regex_patterns == null || regex_patterns.length == 0 )
    {
        return;
    }
    
    if( regex_patterns.length == null )
    {
        un_colorize( regex_patterns );
    }
    else
    {
        for(var i=0; i<regex_patterns.length; i++)
        {
            un_colorize( regex_patterns[i] );
        }
    }
}

//
// 对多个链接进行“修改”
//
function change_links( linkname, caption, tip )
{
    var alinks = document.getElementsByName( linkname );
    
    if( alinks == null )
        return;

    if( alinks.length == null )
    {
        setInnerText( alinks, caption );
        alinks.title     = tip;
    }
    else
    {
        for(var i=0; i<alinks.length; i++)
        {
            setInnerText( alinks[i], caption );
            alinks[i].title     = tip;
        }
    }
}

//
// 对多个 check box 修改
//
function change_chks( chkname, chk )
{
    var chks = document.getElementsByName( chkname );

    if( chks == null )
        return;

    if( chks.length == null )
    {
        chks.checked = chk;
    }
    else
    {
        for(var i=0; i<chks.length; i++)
        {
            chks[i].checked = chk;
        }
    }
}

//
// 对多个元素进行显示/隐藏
//
function show_tags( tagname, isshow )
{
    var tags = document.getElementsByName( tagname );
    
    if( tags == null )
        return;
        
    if( tags.length == null )
    {
        tags.style.display = isshow ? "" : "none";
    }
    else
    {
        for(var i=0; i<tags.length; i++)
        {
            tags[i].style.display = isshow ? "" : "none";
        }
    }
}
