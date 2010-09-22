require "bin\\IRCInterface.rb"
require "bin\\IRCLogger.rb"
require "Time"

class Jarvis

	@int
	@logger
	@rooms
	@auth
	@nick
	@connected
	@parseChan

	def initialize(hostname,rooms, auth, nick, port=6667)
		@int = IRCInterface.new hostname,port
		@logger = IRCLogger.new("log\\log-#{timeStamp}.txt")
		@rooms = []
		for room in rooms do
			room =~ /#.*/ ? @rooms << room : @rooms << "#" + room
		end
		@auth = auth
		@nick = nick
		@parseChan = true
	end
	
	def shutDown
		@logger.close# if !(@logger.closed?)
		@int.disconnect
		exit
	end
	
	def timeStamp
		Time.now.strftime("%a-%b-%d-%H-%M-%S")
	end
	
	def joinAll
		for chan in @rooms do @int.join(chan) end
	end
	
	def auth(name)
		@auth.include? name
	end
	
	def parse(message)
		chan = $1 if /PRIVMSG (#\S*)/ =~ message.strip
		name = $1 if /:([\w|\W]*)![\w|\W]*@/ =~ message.strip
		mes = $1 if /PRIVMSG #[\w|\W]* :([\w|\W]*)/ =~ message.strip
		puts message  #always print the message
		@int.tell "PONG #{$1}" if /^PING\s(.*)/ =~ message.strip #if I get a ping, I need to tell a pong back with the appropriate number.
		@logger.log mes + " " if !mes.nil?
		
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
	end
	
	def main
		trap("INT") do shutDown end
		trap("TERM") do shutDown end
	
		@int.tell "USER #{@nick} #{@nick} #{@nick} #{@nick}"
		@int.tell "NICK #{@nick}"
		@int.ping
		joinAll
		loop do
			toval = @int.gets
			parse toval
		end
   end
   
end