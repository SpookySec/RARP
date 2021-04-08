require_relative "logger"

unless Process.euid == 0
	error("You need root privs to run this.")
	exit!
end

require "tty-prompt"
require "tty-reader"

require_relative "commands"
require_relative "utils"

terminate = Proc.new { puts; warning("Exiting..."); exit! }
reader = TTY::Reader.new(interrupt: terminate)
prompt = TTY::Prompt.new(interrupt: terminate)
rarp = RARP.new

puts Utils::BANNER

loop do
	input = reader.read_line(Utils::PROMPT).split
	unless input.first.nil?
		unless Utils::CMDS.include? input.first
			warning("Command: '#{input.first}' not found")
			next
		end

		case input.first
		when "clear"
			system("clear")
		when "scan"
			rarp.scan
		when "info"
			if rarp.ips.empty?
				error("No IPs found in buffer!")
			else
				begin
					parsed = rarp.ipinfo prompt.select("Select a host:", rarp.ips)
					info("IP : #{parsed[0]}")
					info("MAC: #{parsed[1]}")
					info("OUI: #{parsed[2]}")
				rescue
					warning("Host seems down or invalid!")
				end
			end
		when "help"
			rarp.help
		when "config"
			rarp.config
		when "hosts"
			unless rarp.ips.empty?
				rarp.ips.each do |ip|
					info(ip)
				end
			else
				error("No IPs found in buffer!")
			end
		when "attack"
			targets = Hash[rarp.arp_hosts.collect {|host| [host.ip_addr, host.mac] } ]
			unless rarp.ips.empty?
				target = prompt.select("Select a host:", targets)
				print "\e[1A\e[K"
				rarp.attack(target)
			else
				error("No IPs found in buffer!")
			end
		when "quit"
			puts "\e[2A"
			terminate.call
		end
	end
end
