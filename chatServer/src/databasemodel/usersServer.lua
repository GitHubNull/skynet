local skynet = require "skynet"
local usersDao = require "usersDao"
local usersServer = {}

function usersServer:init( )
	usersDao:init( )
end

function usersServer:login( users_id, users_pwd )
	skynet.error("usersServer.lua->usersServer:login", users_id, users_pwd)
	if((nil ~= users_id) and ( nil ~= users_pwd)) then
		local tmppwd = usersDao:searchUsersPwdById(users_id)
		if(tmppwd == users_pwd) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function usersServer:register( users_id, users_name, users_pwd )
	skynet.error("usersServer.lua->command:register", users_id, users_name, 
					users_pwd)
	if((nil ~= users_id) and ( nil ~= users_name) and (nil ~= users_pwd)) then
		return usersDao:addUsers(users_id, users_name, users_pwd)
	else
		return false
	end
end

function usersServer:changeName( users_id, users_name )
	if((nil ~= users_id) and ( nil ~= users_name)) then
		return usersDao:updateUsersName(users_id, users_name)
	else
		return false
	end
end

function usersServer:changePwd( users_id, users_pwd )
	if((nil ~= users_id) and ( nil ~= users_name)) then
		return usersDao:updateUsersName(users_id, users_pwd)
	else
		return false
	end
end

function usersServer:findUsersByUID( users_id )
	if(nil ~= users_id) then
		return usersDao:searchUsersById(users_id)
	else
		return nil
	end
end

function usersServer:findUsersByName( users_name )
	if(nil ~= users_name) then
		return usersDao:searchUsersByName(users_name)
	else
		return nil
	end
end

return usersServer