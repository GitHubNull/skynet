local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
	.package {
		type 0 : integer
		session 1 : integer
	}

	login 1 {
		request {
			uid 0 : string
			pwd 1 : string
		}
		response {
			result 0 : string
		}
	}

	register 2 {
		request {
			uid 0 : string
			name 1 : string
			pwd 2 : string
		}
		response {
			result 0 : string
		}
	}

	quit 3 {}

	findUsersByUID 4 {
		request {
			uid 0 : string
			srcUID 1 : string
		}
		response {
			result 0 : string
		}
	}

	findUsersByName 5 {
		request {
			name 0 : string
			srcUID 1 : string
		}
		response {
			result 0 : string
		}
	}
]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

]]

return proto
