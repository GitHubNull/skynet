local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local netpack = require "netpack"
local socket = require "socket"
local sprotoloader = require "sprotoloader"

local CMD = {}
local REQUEST = {}
local gate
local host
local send_request
local fd
local cnt = 0

function REQUEST.login(conf)
	local args = conf.args
	local response = conf.response
	print("loginAgent.lua->REQUEST:login", args.uid, args.pwd)
	if(3 >= cnt) then
		local r = skynet.call("databaseServer", "lua", "login", args.uid, 
			args.pwd)
		if(true == r) then
			local res = response({ result = "login OK."})
			send_package(res)
			skynet.call(gate, "lua", "passLogin", fd, gate, args.uid)
			skynet.exit()
		else
			local res = response({ result = "login KO."})
			send_package(res)
			cnt = cnt + 1
		end	
	else
		skynet.call(gate, "lua", "kick", fd)
	end
end

function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

function CMD.start(conf)
	fd = conf.fd
	gate = conf.gate
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, _, name, args, response)
		local f = assert(REQUEST[name])
		local conf = {args = args, response = response}
		f(conf)
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)