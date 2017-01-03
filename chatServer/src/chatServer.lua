local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
require "skynet.manager"
local sprotoloader = require "sprotoloader"

local host
local send_request
local command = {}
local REQUEST = {}
local usersConfTable = {} 

local function userInfo2Str(tab)
	local res = "users_id\tusers_name\n"
	for k, v in pairs(tab) do
		res = res .. v.users_id.."\t"..users_name
	end
	return res
end

function REQUEST.findUsersByUID(args, response)
	local time = os.date("%Y-%m-%d %H:%M:%S")
	skynet.error(time.." chatServer.lua->REQUEST.findUsersByUID...")

	local r = skynet.call("databaseServer", "lua", "findUsersByUID", args.uid)
	if(nil ~= r) then
		local tmp = "\n\nusers_id\tusers_name\n"..r.users_id.."\t"..r.users_name.."\n"
		local pack = response({result = tmp})
		local fd = usersConfTable[args.srcUID].fd
		send_package(fd, pack)
	else
		local tmp = "\n\nusers_id\tusers_name\nNull\tNull\n"
		local pack = response({result = tmp})
		local fd = usersConfTable[args.srcUID].fd
		send_package(fd, pack)
	end
end

function REQUEST.findUsersByName(args, response)
	local time = os.date("%Y-%m-%d %H:%M:%S")
	skynet.error(time.." chatServer.lua->REQUEST.findUsersByName...")

	local r = skynet.call("databaseServer", "lua", "findUsersByName", args.name)
	if(nil ~= r) then
		local tmp = "\n\nusers_id\tusers_name\n"..r.users_id.."\t"..r.users_name.."\n"
		local pack = response({result = tmp})
		local fd = usersConfTable[args.srcUID].fd
		send_package(fd, pack)
	else
		local tmp = "\n\nusers_id\tusers_name\nNull\tNull\n"
		local pack = response({result = tmp})
		local fd = usersConfTable[args.srcUID].fd
		send_package(fd, pack)
	end
end

function command.login(conf)
	local time = os.date("%Y-%m-%d %H:%M:%S")
	skynet.error(time.." chatServer.lua->command.login...", conf.fd, conf.gate, 
		conf.uid)

	local userConf = {}
	userConf.fd = conf.fd
	userConf.gate = conf.gate
	userConf.uid = conf.uid
	usersConfTable[conf.uid] = userConf
end

function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, name, args, response)
		if type == "REQUEST" then
			local f = assert(REQUEST[name])
			f(args, response)
		else
			local f = assert(RESPONSE[name])
			f(args, response)
		end
	end
}

skynet.start(function()
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "chatServer"
end)