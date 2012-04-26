
var str_login    = "&#30331;&#24405;"; // Login
var str_logout   = "&#27880;&#38144;"; // Logout
var str_register = "&#27880;&#20876;"; // Register
var str_cancel   = "&#21462;&#28040;"; // Cancel
var str_username = "&#29992;&#25143;"; // User
var str_password = "&#23494;&#30721;"; // Password
var str_about    = "<a href='/zh/feedback.jsp' class='bb' onclick='return feedback(this.href)'>&nbsp;&#21453;&#39304;&nbsp;</a>|<a href='/zh/about.htm' class='bb'>&nbsp;&#20851;&#20110;&nbsp;</a>";

var url_login    = "/zh/user/login.aspx";
var url_logout   = "/zh/user/logout.aspx";
var url_profile  = "/zh/user/profile.aspx";
var url_register = "/zh/user/register.aspx";

var login_user_zh = new Cookie("login_user"   , "/");
var login_user_en = new Cookie("login_user_en", "/");
var login_email   = new Cookie("login_email"  , "/");
var login_keep    = new Cookie("login_keep"   , "/");
var login_chks    = new Cookie("login_chks"   , "/");

var login_user    = login_user_zh;

function feedback(url, about)
{
	if( url == "javascript:void(0)" ) return false;

    var href = location.href, rfpos = href.indexOf('refer=');
    location.href = url + (rfpos >= 0 ? ("?" + href.substr(rfpos)) : ("?refer=" + escape(href) + (about != null ? ("&about=" + escape(about)) : "")));
    return false;
}

function show_userinfo()
{
    var inner_src  = "";

    if( login_email.toString() != "" )
    {
        if( login_user.toString() == "" ) login_user.Value = login_email.toString();
        inner_src = "<a href='" + url_profile + "' class='bb' onclick='return feedback(this.href)'>&nbsp;" + formatstr(login_user.toString()) + "&nbsp;</a>|" +
                    "<a href='" + url_logout + "' class='bb' onclick='return feedback(this.href)'>&nbsp;" + str_logout + "&nbsp;</a>|" + str_about;
    }
    else
    {
        inner_src = "<a href='" + url_login + "' class='bb' onclick='return feedback(this.href)'>&nbsp;" + str_login + "&nbsp;</a>|" +
                    "<a href='" + url_register + "' class='bb' onclick='return feedback(this.href)'>&nbsp;" + str_register + "&nbsp;</a>|" + str_about;
    }

    document.write("<span style='padding-bottom: 1px; padding-top: 1px'>" + inner_src + "</span>");
}

show_userinfo();

function keep_userinfo()
{
    var keep = login_keep.toString();
    var re   = /^\d+$/;

    if( re.exec(keep) != null )
    {
        var days = parseInt(keep, 10);
        if( days == 0 ) days = null;

        login_user_zh.Save( days );
        login_user_en.Save( days );
        login_email  .Save( days );
        login_keep   .Save( days );
        login_chks   .Save( days );
    }
}

keep_userinfo();
