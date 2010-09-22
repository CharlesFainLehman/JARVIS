#run from the top-level directory as ruby test/JARVIStest.rb in order to not get lol errors
begin
	require "JARVIS.rb"
	require "yaml"
	
	config = YAML.load_file("config.yaml")
	jarvis = Jarvis.new config['hostname'], config['chan'], config['auth'], config['username']
	jarvis.main

rescue LoadError => e
	puts "Couldn't load a file! Make sure you ran from the top level directory as ruby test/JARVIStest.rb."
	puts e
	exit
	
rescue ArgumentError => e
	puts "Argument error occured. It's probably that you put pound signs before the names of your channel in the config.yaml. Don't you wish that you'd paid attention now?"
	puts e
	exit
end