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
		begin
			@serv = TCPSocket.open(hostname, port)
		rescue SocketError => e
			puts "Could not open connection to host #{hostname} on port #{port}"
			connect("127.0.0.1",6667)
		rescue Errno::ETIMEDOUT => e
			puts "The connection was opened, but failed to respond. Ensure you've opened a connection to the proper server."
			exit
		rescue Errno::EPERM => e
			puts "Could not bind socket. Ensure that the port you wish to connect to is open."
			exit
		end
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
	
	def say(message,chan)
		/\/me ([\W|\w]*)/ =~ message ? tell("PRIVMSG #{chan} :ACTION #{$1}") : tell("PRIVMSG #{chan} :#{message.to_s}") unless message.nil?
	end
	
	def gets
		@serv.gets
	end
	
end