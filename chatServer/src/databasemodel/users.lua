local skynet = require "skynet"
local mysql = require "mysql"
local db
local function on_connect(db)
		db:query("set charset utf8");
end

local users = {}

function users:init( )
	db = mysql.connect({
	host = "127.0.0.1",
	port = 3306,
	database = "chatServer",
	user = "root",
	password = "toor",
	max_packet_size = 1024 * 1024,
	on_connect = on_connect
	})
end

function users:close( )
	mysql.disconnect()
end

function users:insert(users_id, users_name, users_pwd)
	skynet.error("users:insert", users_id, users_name, users_pwd)
	local sql = string.format("insert into users values('%s', '%s', '%s')", 
								users_id, users_name, users_pwd)
	local status = db:query(sql)
	if((0 == status.warning_count) and (1 <= status.affected_rows)) then
		return true
	else
		return false
	end
end

function users:delete(users_id)
	skynet.error("users:delete", users_id)
	local sql = string.format("delete from users where users_id = '%s'", 
								users_id)
	local status = db:query(sql)
	if((0 == status.warning_count) and (1 <= status.affected_rows)) then
		return true
	else
		return false
	end
end

function users:updateName(users_id, users_name)
	skynet.error("users:updateName", users_id, users_name)
	local sql = string.format("update users set users_name = '%s' where "
									.. "users_id = '%s' ", users_name, users_id)
	local status = db:query(sql)
	if((0 == status.warning_count) and (1 <= status.affected_rows)) then
		return true
	else
		return false
	end
end

function users:updatePwd(users_id, users_pwd)
	skynet.error("users:updatePwd", users_id, users_pwd)
	local sql = string.format("update users set users_pwd = '%s' where "
									.. "users_id = '%s' ", users_pwd, users_id)
	local status = db:query(sql)
	if((0 == status.warning_count) and (1 <= status.affected_rows)) then
		return true
	else
		return false
	end
end


function users:selectById(users_id)
	skynet.error("users:selectById", users_id)
	local sql = string.format("select * from users where users_id = '%s'", 
								users_id)
	return db:query(sql)
end

function users:selectByName(users_name)
	skynet.error("users:selectByName", users_name)
	local sql = string.format("select * from users where users_name = '%s'", 
								users_name)
	return db:query(sql)
end

return users