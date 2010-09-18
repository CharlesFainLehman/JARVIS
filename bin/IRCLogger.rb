class IRCLogger
	@logFile
	@loc
	attr_reader :writable, :readable
	
	def initialize(fileName)
		@logFile = File.new(fileName,"w+")
		@loc = fileName
		@writable = true
		@readable = true
	end
	
	def openW
		@logFile = File.open(@loc,"w+")
		@writable = true
		@readable = true
	end
	
	def openR
		@logFile = File.open(@loc)
		@writable = false
		@readable = true
	end
	
	def openA
		@logFile = File.open(@loc,"a+")
		@writable = true
		@readable = true
	end
	
	def close
		@logFile.close
		@writable = false
		@readable = false
	end
	
	def closed?
		@logFile.closed?
	end
	
	def <<(text)
		write text if @writable
	end
	
	def log(text)
		@logFile.write text if @writable
	end
	
	def read
		@logFile.read if @readable
	end
end