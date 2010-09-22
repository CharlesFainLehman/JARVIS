#run from the top-level directory as ruby test/JARVIStest.rb in order to not get lol errors
begin
	require "JARVIS.rb"
	require "yaml"
	
	config = YAML.load_file("config.yaml")
	jarvis = Jarvis.new config['hostname'], config['rooms'], config['auth'], config['username']
	jarvis.main

rescue LoadError => e
	puts "Couldn't load a file! Make sure you ran from the top level directory as ruby test/JARVIStest.rb."
	puts e
	exit
end