#(The .cshrc File)
if ( $?prompt ) then
	set prompt = "\! stardust > "
	set history = 32
	set savehist = 5
	set noclobber
	set filec fignore = ( .o )
	set cdpath = ( /home/jody/ellie/bin /usr/local/bin /usr/bin )
	set ignoreeof
	alias m more
	alias status 'date;du -s'
	alias cd 'cd \!*;set prompt = "\! <$cwd> "'
endif
