# Simple and lightweight lua types annotation module.

## The module was created as a utility for faster gui development for games on the love2d framework, but can be used in any projects where data validators are needed.

1. To use this code download `types.lua`
2. Require it where you need to
3. Examples are in `main.lua`

------

usage:
```Lua
local tp = require 'types'

local variable = tp({ value = 'hello ', type = tp.defTypes.str,
	get = function(self)
		return self.value
	end,
	set = function(self, value)
		return value
	end })
	
variable()
-- or
variable:get()

variable:set('hello world')
-- or
variable:safeset(123456)

-- creating new types
local unsignedInt = tp.defTypes.num * tp.createType(function(value)
	return value >= 0
end)
-- multiplication sign is a logical AND, plus is a logical OR
```

