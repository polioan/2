-- require 'tests' -- tests

-- usage
local tp = require 'types'


-- creating a variable with a specific type
local variable = tp({ value = 3, type = tp.defTypes.num })

-- to get value
variable()
-- or
variable:get()

-- to set value
variable:set(256)
-- or
variable:safeset('some text') -- will not throw error if type aren't valid (returns true - if set was successful)


-- creating variable with any type
local variable = tp({})
-- or
local variable = tp({ value = 9 })
-- or
local variable = tp({ value = 200, type = tp.defTypes.any })

variable:set(123)
variable:set('hello world!')
variable:set({})


-- you can add setter, getter or both
local variable = tp({ value = 'hello ', type = tp.defTypes.str,
	get = function(self)
		return self.value .. 'world'
	end,
	set = function(self, value)
		if string.len(value) < 4 then
			return value .. value
		end

		return value
	end })


-- you  can create your own types
local charType = tp.createType(function(value)
	if type(value) ~= 'string' then
		return false
	end
	return string.len(value) == 1
end) -- createType accepts a callback function that returns true or false

local variable = tp({ value = 'G', type = charType })
variable:safeset('hello') -- false
variable:safeset('H') -- true

-- you can create types based on existing ones
local charOrNumber = charType + tp.defTypes.num -- plus is a logical OR

local variable = tp({ value = 'J', type = charOrNumber })
variable:safeset('h') -- true
variable:safeset(123) -- true

local unsignedInt = tp.defTypes.num * tp.createType(function(value)
	return value >= 0
end) -- multiplication sign is a logical AND

local variable = tp({ value = 0, type = unsignedInt })
variable:safeset(-2) -- false
variable:safeset(123) -- true

-- or for simple types you can just pass function to a type field
local variable = tp({ value = 5, type = function(value)
	return (value == 5) or (value == '5')
end })
