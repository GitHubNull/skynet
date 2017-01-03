package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua"
local Base64 = require "Base64"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8888))
local session = 0
local last = ""
local serverName = {}
serverName.login = "01"
serverName.register = "02"


serverName.chatServer = "03"
serverName.findUsersByUID = "03"
serverName.findUsersByName = "03"


serverName.quit = "04"

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		os.exit()
	end
	return unpack_package(last .. r)
end

local function send_request(name, args)
	session = session + 1
	local str = request(name, args, session)
	str = serverName[name] .. str
	send_package(fd, str)
	print("Request:", session)
end

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print(v)
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end

		print_package(host:dispatch(v))
	end
end

function string.split(str, delimiter)
    if str == nil or str == "" or delimiter == nil or delimiter == "" then
        return nil
    end
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

local function dispatch_cmd(cmd)
	if("quit" == cmd) then
		send_request("quit")
		os.exit()
	else
		local res = string.split(cmd, " ")
		local realcmd = res[1]
		if("login" == realcmd) then
			send_request("login", {uid = res[2], pwd = res[3]})
		elseif("register" == realcmd) then
			send_request("register", {uid = res[2], name = res[3], 
				pwd = res[4]})
		elseif("fubu" == realcmd) then -- fubu == findUsersByUID
			send_request("findUsersByUID", {uid = res[2], srcUID = res[3]})
		elseif("fubn" == realcmd) then -- fubn == findUsersByName
			send_request("findUsersByName", {name = res[2], srcUID = res[3]})
		-- elseif() then
		-- elseif() then
		else
			print("args error.")
		end
	end
end

while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		dispatch_cmd(cmd)
	else
		socket.usleep(100)
	end
end
