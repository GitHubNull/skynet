package.path = package.path .. "./chatServer/src/databasemodel/?.lua;"
local skynet = require "skynet"
require "skynet.manager"
local usersServer = require "usersServer"

local command = {}

function command.login( users_id, users_pwd )
	skynet.error("databaseServer.lua->command:login", users_id, users_pwd)
	return usersServer:login( users_id, users_pwd )
end

function command.register( users_id, users_name, users_pwd )
	skynet.error("databaseServer.lua->command:register", users_id, users_name, 
					users_pwd)
	return usersServer:register( users_id, users_name, users_pwd )
end

function command.findUsersByUID( users_id )
	skynet.error("databaseServer.lua->command:findUsersByUID", users_id)
	local tmp = usersServer:findUsersByUID( users_id )
	if(nil ~= tmp) then
		return {users_id = tmp.users_id, users_name = tmp.users_name}
	else
		return nil
	end
end

function command.findUsersByName( users_name )
	skynet.error("databaseServer.lua->command:findUsersByName", users_name)
	local tmp = usersServer:findUsersByName( users_name )
	if(nil ~= tmp) then
		return {users_id = tmp.users_id, users_name = tmp.users_name}
	else
		return nil
	end
end

skynet.start(function()
	usersServer:init( )
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "databaseServer"
end)