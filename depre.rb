#talking to me#
		if !name.nil? and auth name then
			@int.tell "QUIT" and exit if message.strip.match(/PRIVMSG #{@nick} :!quit/)
			@int.join($1) if message.strip.match(/PRIVMSG #{@nick} :!join ([\s|\S]*)/)
			@int.tell($1) if message.strip.match(/PRIVMSG #{@nick} :!tell ([\s|\S]*)/)
			@int.part($1) if message.strip.match(/PRIVMSG #{@nick} :!part ([\s|\S]*)/)
			@nick = $1 and tell "NICK #{$1}" if message.strip.match(/PRIVMSG #{@nick} :!nick ([\s|\S]*)/)
			@int.say($2,$1) if message.strip.match(/PRIVMSG #{@nick} :!say (#\S*) ([\s|\S]*)/)
			@parseChan = false if /PRIVMSG #{@nick} :!parse off/ =~ message.strip
			@parseChan = true if /PRIVMSG #{@nick} :!parse on/ =~ message.strip
			@auth << $1 if /PRIVMSG #{@nick} :!auth ([\W|\w]*)/ =~ message.strip
		end