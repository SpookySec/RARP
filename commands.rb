require "arp_scan"
require "tty-progressbar"

require_relative "utils"
require_relative "logger"

class RARP
	attr_reader :ips

	def initialize
		@scanned = false
		@report = nil
		@hosts = Array.new
		@ips = Array.new
	end

	def scan
		bar = TTY::ProgressBar.new("Scanning... [:bar]", bar_format: :box, total: 100, clear: true)
		@report = ARPScan("--localnet");
		100.times {
			bar.advance
			sleep(0.007)
		}

		@scanned = true
		@hosts = @report.hosts
		@ips = @hosts.map { |h| h.ip_addr }
		@ips.uniq!
		@ips.sort_by! {|ip| ip.split('.').map{|octet| octet.to_i}}
		info("Successfully scanned!")
		return @hosts.uniq!
	end

	def ipinfo(ip)
		begin
			report = ARPScan(ip)
			info = report.hosts.first
			[info.ip_addr, info.mac, info.oui]
		rescue
			error("Please make sure it's a valid IP!")
			return
		end
	end

	def help
		info("Current commands:")
		Utils::CMDS.each do |cmd|
			if cmd.eql? "info" or cmd.eql? "attack"
				puts "\t- #{cmd} [ip]"
			else
				puts "\t- #{cmd}"
			end
		end
	end

	def hosts
		unless @scanned
			warning("Please run 'scan' to scan your network")
			return
		end

		@ips.each do |ip|
			info(ip)
		end
	end

	def attack
		warning("Coming soon...")
	end

	def config
		unless @scanned
			warning("Please run 'scan' to scan your network")
			return
		end

		info("Interface: #{@report.interface}")
		info("Range: #{@report.range_size}")
		info("Alive: #{@report.reply_count}")
		info("Last scan time: #{@report.scan_time	}")
		info("Version: #{@report.version}")
	end
end