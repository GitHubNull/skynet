local port = 8888
local maxclient = 64
local nodelay = true
local gatewayconfig = {}
gatewayconfig.conf = { port = port, maxclient = maxclient, nodelay = nodelay}
return gatewayconfig