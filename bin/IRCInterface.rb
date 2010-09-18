require 'socket'

class IRCInterface
	attr_accessor :hostname, :port
	attr_reader :serv
	
	def initialize(hostname, port)
		@hostname = hostname
		@port = port
		connect hostname, port
	end
	
	def connect(hostname, port)
		@serv = TCPSocket.open(hostname, port)
	end
	
	def disconnect
		@serv.close
	end
	
#########################################################
	
	def ping
		cur = self.gets
		while !(/^PING\s(.*)/ =~ cur); puts cur; cur = @serv.gets	end
		tell "PONG #{$1}" if /^PING\s(.*)/ =~ cur
	end
	
#########################################################

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
	
	def gets
		@serv.gets
	end
	
end