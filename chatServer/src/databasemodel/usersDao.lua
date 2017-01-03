local skynet = require "skynet"
local users = require "users"
local usersDao = {}

function usersDao:init( )
	users:init( )
end

function usersDao:addUsers(users_id, users_name, users_pwd)
	skynet.error("usersDao:addUsers", users_id, users_name, users_pwd)
	local tmptab = users:selectById(users_id)
	if(1 > #tmptab) then
		return users:insert(users_id, users_name, users_pwd)
	else
		return false
	end
end

function usersDao:deleteUsers(users_id)
	skynet.error("usersDao:deleteUsers", users_id)
	local tmptab = users:selectById(users_id)
	if(1 <= #tmptab) then
		return users:delete(users_id)
	else
		return false
	end
end

function usersDao:updateUsersName(users_id, users_name)
	skynet.error("usersDao:updateUsersName", users_id)
	local tmptab = users:selectById(users_id)
	if(1 <= #tmptab) then
		return users:updateName(users_id, users_name)
	else
		return false
	end
end

function usersDao:updateUsersPwd(users_id, users_pwd)
	skynet.error("usersDao:updateUsersPwd", users_id, users_pwd)
	local tmptab = users:selectById(users_id)
	if(1 <= #tmptab) then
		return users:updatePwd(users_id, users_pwd)
	else
		return false
	end
end

function usersDao:searchUsersById(users_id)
	skynet.error("usersDao:searchUsersById", users_id)
	local tmptab = users:selectById(users_id)
	if(1 <= #tmptab) then
		return tmptab[1]
	else
		return nil
	end
end

function usersDao:searchUsersByName(users_name)
	skynet.error("usersDao:searchUsersByName", users_name)
	local tmptab = users:selectByName(users_name)
	if(1 <= #tmptab) then
		return tmptab[1]
	else
		return nil
	end
end

function usersDao:searchUsersNameById(users_id)
	skynet.error("usersDao:searchUsersNameById", users_id)
	local tmptab = users:selectById(users_id)
	if(1 <= #tmptab) then
		return tmptab[1].users_name
	else
		return nil
	end
end

function usersDao:searchUsersPwdById(users_id)
	skynet.error("usersDao:searchUsersPwdById", users_id)
	local tmptab = users:selectById(users_id)
	if(1 <= #tmptab) then
		return tmptab[1].users_pwd
	else
		return nil
	end
end

return usersDao