description = [[
Get MAC address from printers
]]

---
-- @usage
-- nmap -sS -p 9100 --script snmp-printer-mac <target>
--
-- @output
-- |_snmp-printer-mac: 00:01:02:03:04:AB
-- <snip>
--


author = "Esteban Dauksis"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}
dependecies = {"snmp-brute"}

require "snmp"
require "shortport"

-- I prefer a portrule for tcp 9100 than upd 161 for printer discovery
-- portrule = shortport.portnumber(161, "udp", {"open", "open|filtered"})

portrule = shortport.portnumber(9100, "tcp", "open")

action = function(host,port)

	local socket = nmap.new_socket()

	socket:set_timeout(5000)

	local catch = function()
		socket:close()
	end

	local try = nmap.new_try(catch)	

	try(socket:connect(host, 161, "udp"))

	local payload
	local options = {}
	options.reqId = 28428 -- pa que?
	payload = snmp.encode(snmp.buildPacket(snmp.buildGetRequest(options,"1.3.6.1.2.1.2.2.1.6.1")))

        try(socket:send(payload))
        
        local status
        local response
        
        status, response = socket:receive_bytes(1)

        if (not status) or (response == "TIMEOUT") then 
                return
        end
	
	nmap.set_port_state(host, port, "open")

	local result

        local r = snmp.fetchFirst(response)
	if r ~= "" then
		res1 = string.format("%02x:%02x:%02x:%02x:%02x:%02x",string.byte(r),string.byte(r,2),string.byte(r,3),string.byte(r,4),string.byte(r,5),string.byte(r,6)) 
		return res1
	end


	local payload
	local options = {}
	options.reqId = 28429 -- pa que?
        payload = snmp.encode(snmp.buildPacket(snmp.buildGetRequest(options, "1.3.6.1.2.1.2.2.1.6.2")))
        
        try(socket:send(payload))
        
        status, response = socket:receive_bytes(1)

        if (not status) or (response == "TIMEOUT") then
                return
        end
        
	local r2 = snmp.fetchFirst(response)
	if r2 ~= "" then
		res2 = string.format("%02x:%02x:%02x:%02x:%02x:%02x",string.byte(r2),string.byte(r2,2),string.byte(r2,3),string.byte(r2,4),string.byte(r2,5),string.byte(r2,6))
		return res2
	end


	try(socket:close())
	
	
end