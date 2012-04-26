//
// Cookie 类
//
// Copyright 2005 (c) RegExLab.com
//
// Author: 史寿伟 ( Sswater Shi )
//         sswater@gmail.com
//

//
// Cookie
//
function Cookie( cookie_name, cookie_path )
{
	this.m_name  = cookie_name;
	this.Path    = cookie_path;

	this.Value   = null;
	this.Expires = null;
	this.Domain  = null;
	this.Secure  = false;

	//
	// 保存（天数）
	//
	this.Save = function( days )
	{
		if( this.Value == null || this.Value == "" )
		{
			this.Delete();
		}
		else
		{
			if( days != null )
			{
				this.Expires = new Date();
				this.Expires.setTime( this.Expires.getTime() + (24 * 60 * 60 * 1000 * days) );
			}

			document.cookie = this.m_name + "=" + escape_plus(this.Value) 
				+((this.Expires == null) ? "" : ("; expires="+ this.Expires.toGMTString()))
				+((this.Path    == null) ? "" : ("; path="   + this.Path)                 )
				+((this.Domain  == null) ? "" : ("; domain=" + this.Domain)               )
				+((this.Secure  == true) ? "; secure" : "");
		}
	}

	//
	// 读入
	//
	this.Load = function()
	{
		var name_pos = document.cookie.indexOf( this.m_name + "=" );

		if( name_pos < 0 )
		{
			this.Value = "";
		}
		else
		{
			var ends_pos = document.cookie.indexOf( ";", name_pos );

			if( ends_pos < 0 )
				this.Value = unescape_plus( document.cookie.substr( name_pos + this.m_name.length + 1 ) );
			else
				this.Value = unescape_plus( document.cookie.substring( name_pos + this.m_name.length + 1, ends_pos ) );
		}

		return this.Value;
	}

	//
	// 删除
	//
	this.Delete = function()
	{
		var exp = new Date();
		exp.setTime (exp.getTime() - 1);

		document.cookie = this.m_name + "=; expires=" + exp.toGMTString()
			+((this.Path    == null) ? "" : ("; path="   + this.Path)   )
			+((this.Domain  == null) ? "" : ("; domain=" + this.Domain) )
			+((this.Secure  == true) ? "; secure" : "");
	}

	//
	// 值
	//
	this.toString = function()
	{
		return this.Value.toString();
	}

	// 初始化
	this.Load();
}

