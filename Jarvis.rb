require "bin\\IRCInterface.rb"
require "bin\\IRCLogger.rb"
require "Time"

class Jarvis

	attr_reader :int, :logger, :auth, :parseChan
	attr_accessor :chans, :nick, :connected

	def initialize(hostname,chans, auth, nick, port=6667)
		@logger = IRCLogger.new("log\\log-#{timeStamp}.txt")
		@chans = []
		for chan in chans do
			chan =~ /#.*/ ? @chans << chan : @chans << "#" + chan
		end
		@auth = auth
		@nick = nick
		@parseChan = true
		@int = IRCInterface.new hostname,port
	end
	
	def setup #setup for afer connection
		@int.tell "USER #{@nick} #{@nick} #{@nick} #{@nick}"
		@int.tell "NICK #{@nick}"
		@int.ping
	end
	
	def shutDown
		@logger.close
		@int.disconnect
		exit
	end
	
	def timeStamp
		Time.now.strftime("%a-%b-%d-%H-%M-%S")
	end
	
	def joinAll
		for chan in @chans.clone do join chan end
	end

############################################################
	
	def auth(name)
		@auth.include? name
	end

############################################################
	
	#doesn't work for some reason...
	def join(chan)
		if chan =~ /#.*/ then
			@int.join(chan)
			@chans << chan
		else
			@int.join("#" + chan)
			@chans << "#" + chan
		end
	end
	
	def part(chan)
		@int.part chan
		@chans.delete_if {|c| c == chan}
	end
	
	def say(message, chan)
		@int.say message, chan
	end
	
	def gets
		@int.gets
	end
	
############################################################
	def parse(message)
		chan = $1 if /PRIVMSG (#\S*)/ =~ message.strip
		name = $1 if /:([\w|\W]*)![\w|\W]*@/ =~ message.strip
		mes = $1 if /PRIVMSG #[\w|\W]* :([\w|\W]*)/ =~ message.strip
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
	
		setup
		joinAll
	
		loop do
			toval = @int.gets
			puts toval
			parse toval
		end
   end
   
end