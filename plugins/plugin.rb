class Plugin
	@patterns #the patterns that matches to the plugin
	@interface #the Redstone instance
	@approvals #the levels of approval that are allowed to use this plugin
	
	def initialize(int)
		@patterns = [/!default/,/!test/] #set the @pattern here
		@interface = int
		@approvals = [0,1,2]
	end
	
	def match?(str)
		for i in (0..@patterns.length) do
			if @patterns[i] =~ str then return i end
		end
		return -1
	end
	
	def patterns
		@patterns
	end
	
	def approvals
		@approvals
	end
	
	def run(str,usr,regexpPos, apLvl)
		i = match? str
		if i == 0 then
		
		elsif i == 1 then
			
		end
	end
end