require "colorize"

def warning(msg)
	msg = msg.to_s
	puts "#{'['.colorize(:white)}#{'!'.colorize(:yellow)}#{']'.colorize(:white)} #{msg.colorize(:yellow)}"
end

def info(msg)
	msg = msg.to_s
	puts "#{'['.colorize(:white)}#{'*'.colorize(:green)}#{']'.colorize(:white)} #{msg.colorize(:green)}"
end

def error(msg)
	msg = msg.to_s
	puts "#{'['.colorize(:white)}#{'-'.colorize(:red)}#{']'.colorize(:white)} #{msg.colorize(:red)}"
end