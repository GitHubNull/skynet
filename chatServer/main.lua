package.path = package.path .. "./chatServer/src/?.lua;"
local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local gatewayconfig = require "gatewayconfig"

skynet.start(function()
	local conf = { port = port, maxclient = maxclient, nodelay = nodelay}
	skynet.error("Server start")
	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console",8000)
	-- local gateway = skynet.newservice("gateway")
	if(nil ~= conf) then
		for k, v in pairs(conf) do
			print(k, v)
		end
	end
	-- skynet.call(gateway, "lua", "open", conf)
	-- skynet.newservice("databaseServer")
	-- skynet.newservice("chatServer")
	-- skynet.exit()
end)
