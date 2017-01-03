local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local netpack = require "netpack"

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handler = {}
local CMD = {}
local connection = {}
local loginedUsers = {}
local loginAgent = {}
local registerAgent = {}
local serverName = {}
serverName["01"] = "login"
serverName["02"] = "register"
serverName["03"] = "chatServer"
serverName["04"] = "quit"

local function forward(serverCode, fd, msg, sz)
	local server = assert(serverName[serverCode])
	if("login" == server) then
		if(nil == loginAgent[fd]) then
			loginAgent[fd] = skynet.newservice("loginAgent")
			skynet.call(loginAgent[fd], "lua", "start", { gate = skynet.self(),
			 fd = fd})
		end
		skynet.redirect(loginAgent[fd], fd, "client", 0, msg, sz)
	elseif("register" == server) then
		if(nil == registerAgent[fd]) then
			registerAgent[fd] = skynet.newservice("registerAgent")
			skynet.call(registerAgent[fd], "lua", "start", { gate = skynet.self(),
			 fd = fd})
		end
		skynet.redirect(registerAgent[fd], fd, "client", 0, msg, sz)
	elseif("quit" == server) then
		local time = os.date("%Y-%m-%d %H:%M:%S")
		local addr = connection[fd].addr
		skynet.error(time.." fd: "..fd.." addr: "..addr.." close.")
		gateserver.closeclient(fd)
		connection[fd] = nil
	else
		if(true == loginedUsers[fd]) then
			skynet.redirect("chatServer", fd, "client", 0, msg, sz)
		else
			local time = os.date("%Y-%m-%d %H:%M:%S")
			local addr = connection[fd].addr
			skynet.error(time.." fd: "..fd.." addr: "..addr.." unauthorized! close it.")
			gateserver.closeclient(fd)
			connection[fd] = nil
		end
	end
end

function handler.message(fd, msg, sz)
	local tmp = netpack.tostring(msg, sz)
	local serverCode = string.sub(tmp, 1, 2)
	msg = string.sub(tmp, 3, sz)
	forward(serverCode, fd, msg, sz)
end

function handler.connect(fd, addr)
	local time = os.date("%Y-%m-%d %H:%M:%S")
	skynet.error(time.." fd: "..fd.." addr: "..addr.." connect.")	
	connection[fd] = {fd = fd, addr = addr}
	loginedUsers[fd] = false
	gateserver.openclient(fd)
end

function handler.disconnect(fd)
	if connection[fd] then
		connection[fd] = nil
	end
end

function handler.error(fd, msg)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "error", fd, msg)
end

function handler.warning(fd, size)
	skynet.send(watchdog, "lua", "socket", "warning", fd, size)
end

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

function CMD.passLogin(source, fd, gate, uid)
	loginedUsers[fd] = true
	loginAgent[fd] = nil
	local conf = {fd = fd, gate = gate, uid = uid}
	skynet.call("chatServer", "lua", "login", conf)
end

function CMD.passRegister(source, fd)
	registerAgent[fd] = nil
end

function CMD.closeLoginClient(source, fd)
	-- body
end

function CMD.kick(source, fd)
	gateserver.closeclient(fd)
end


gateserver.start(handler)