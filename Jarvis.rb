require "bin/IRCInterface.rb"
require "bin/IRCLogger.rb"
require "time"

class Jarvis

	attr_reader :int, :logger, :auth, :parseChan
	attr_accessor :chans, :nick, :connected

	def initialize(hostname,chans, auth, nick, port=6667)
		@logger = IRCLogger.new("log/log-#{timeStamp}.txt")
		@chans = []
		for chan in chans do
			chan =~ /#.*/ ? @chans << chan : @chans << "#" + chan
		end
		@auth = auth
		@nick = nick
		@parseChan = true
		
		@cmds = []
		Dir.foreach("./plugins") {|file|
			if /([\w|\W]*?).rb/ =~ file then #if it's a ruby file
                unless file == "plugin.rb" #ignore plugin superclass
                    begin
                        require "plugins/" + file
                        @cmds << Kernel.const_get(file.gsub(/.rb$/, '')).new(self)
                    rescue NameError => e
                        puts "#{file} failed to load into a class. Name of class must be constant!"
                    end
                end
			end
		}
		
		@int = IRCInterface.new hostname,port
	end
	
	def setup #setup for afer connection
		@int.tell "USER #{@nick} #{@nick} #{@nick} #{@nick}"
		@int.tell "NICK #{@nick}"
		ping
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
			#@chans << chan
		else
			@int.join("#" + chan)
			#@chans << "#" + chan
		end
	end
	
	def part(chan)
		@int.part chan
		@chans.delete_if {|c| c == chan}
	end
	
	def say(message, chan)
		@int.say message, chan
	end
	
	def ping(mes = "")
		@int.ping mes
	end
	
	def gets
		@int.gets
	end
	
	def getApproval(name)
		1
	end
	
	def write(w)
		@int.write w
	end
	
############################################################
	def parse(message)
		chan = $1 if /PRIVMSG (#\S*)/ =~ message.strip
		name = $1 if /:([\w|\W]*)![\w|\W]*@/ =~ message.strip
		mes = $1 if /PRIVMSG #[\w|\W]* :([\w|\W]*)/ =~ message.strip
		@int.tell "PONG #{$1}" if /^PING\s(.*)/ =~ message.strip 
		@logger.log mes + " " if !mes.nil?
		
		for cmd in @cmds do
			if cmd.match?(mes) >= 0 and cmd.approvals.include?(getApproval(name)) then
				cmd.run(mes,name, cmd.match?(mes), getApproval(name))
			end
		end
	end
	
	def main
		trap("INT") do shutDown end
		trap("TERM") do shutDown end
	
		setup
		joinAll
	
		loop do
			outputs = @int.gets
			for output in outputs do
				puts output
				parse output
			end
		end
   end
   
end