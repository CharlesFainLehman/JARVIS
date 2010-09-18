require 'socket'

class Jarvis

	@hostname
	@port
	@serv
	@rooms
	@auth
	@nick
	@connected
	@parseChan

	def initialize(hostname,rooms, auth, nick, port=6667)
		@hostname = hostname
		@port = port
		@rooms = rooms
		@auth = auth
		@nick = nick
		@parseChan = true
	end
	
	def connect
		@serv = TCPSocket.open(@hostname, @port)
		tell "USER #{@nick} #{@nick} #{@nick} #{@nick}"
		tell "NICK #{@nick}"
		@connected = true
	end
	
	def joinAll
		for chan in @rooms do join(chan) end
	end
	
	def getPing
		cur = @serv.gets
		while !(/^PING\s(.*)/ =~ cur); cur = @serv.gets	end
		tell "PONG #{$1}" if /^PING\s(.*)/ =~ cur
	end
	
	def tell(message)
		@serv.send message + "\r\n", 0
	end

	def join(chan)
		tell("JOIN #{chan}")
	end
	
	def part(chan)
		tell("PART #{chan}")
	end
	
	def say(message,room)
		/\/me ([\W|\w]*)/ =~ message ? tell("PRIVMSG #{room} :ACTION #{$1}") : tell("PRIVMSG #{room} :#{message.to_s}") unless message.nil?
	end
	
	def auth(name)
		@auth.include? name
	end
	
	def parse(message)
		chan = $1 if /PRIVMSG (#\S*)/ =~ message.strip
		name = $1 if /:([\w|\W]*)![\w|\W]*@/ =~ message.strip
		mes = $1 if /PRIVMSG #[\w|\W]* :([\w|\W]*)/ =~ message.strip
		puts message  #always print the message
		tell "PONG #{$1}" if /^PING\s(.*)/ =~ message.strip #if I get a ping, I need to tell a pong back with the appropriate number.
		
		#talking to me#
		if !name.nil? and auth name then
			tell "QUIT" and exit if message.strip.match(/PRIVMSG #{@nick} :!quit/)
			join($1) if message.strip.match(/PRIVMSG #{@nick} :!join ([\s|\S]*)/)
			tell($1) if message.strip.match(/PRIVMSG #{@nick} :!tell ([\s|\S]*)/)
			part($1) if message.strip.match(/PRIVMSG #{@nick} :!part ([\s|\S]*)/)
			@nick = $1 and tell "NICK #{$1}" if message.strip.match(/PRIVMSG #{@nick} :!nick ([\s|\S]*)/)
			say($2,$1) if message.strip.match(/PRIVMSG #{@nick} :!say (#\S*) ([\s|\S]*)/)
			@parseChan = false if /PRIVMSG #{@nick} :!parse off/ =~ message.strip
			@parseChan = true if /PRIVMSG #{@nick} :!parse on/ =~ message.strip
			@auth << $1 if /PRIVMSG #{@nick} :!auth ([\W|\w]*)/ =~ message.strip
		end
	end
	
	def main
		connect
		getPing #needs to listen for first ping
		joinAll
		loop do
			toval = @serv.gets #this is the bit that parses incoming text. Seems to work okay...
			parse toval
		end
   end
   
end

jarvis = Jarvis.new "irc.esper.net",["#dixie"],"Faxanavia","JARVIS"
jarvis.main