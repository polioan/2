local tp = require 'types'

local function areError(callback)
  local status = pcall(callback)
  return not status
end

local testCount = 0
local notOkTestCount = 0
local function test(value, needValue, desc)
  testCount = testCount + 1
  local code = 'ok'
  if value ~= needValue then
    code = 'not ok'
    notOkTestCount = notOkTestCount + 1
  end
  print('test ' .. testCount, tostring(value) .. ' and ' .. tostring(needValue), code, desc or '')
end

test(areError(function()
  local a = tp()
end), false)

test(areError(function()
  local a = tp(3)
end), true)

test(areError(function()
  local a = tp({ get = 3 })
end), true)

test(areError(function()
  local a = tp({ set = 3 })
end), true)

test(areError(function()
  local a = tp({ get = function()
  end })
end), false)

test(areError(function()
  local a = tp({ set = function()
  end })
end), false)

test(areError(function()
  local a = tp({})
end), false)

local a = tp({ value = 4 })
test(a:get(), 4)
test(a(), 4)

local a = tp({ value = 4, get = function(self)
  return self.value + 1
end })
test(a:get(), 5)
test(a(), 5)

test(areError(function()
  tp.createType(3)
end), true)

test(areError(function()
  tp.createType()
end), true)

local numType = tp.createType(function(value)
  return type(value) == 'number'
end)

test(numType(), false)
test(numType('3'), false)
test(numType(3), true)

local intNum = tp.createType(function(value)
  return value > 0
end)

local intNumFinal = numType * intNum

test(intNumFinal(), false)
test(intNumFinal('3'), false)
test(intNumFinal(-3), false)
test(intNumFinal(3), true)

local intNumFinal = tp.createType(function(value)
  return type(value) == 'number'
end) * tp.createType(function(value)
  return value > 0
end)

test(intNumFinal(), false)
test(intNumFinal('3'), false)
test(intNumFinal(-3), false)
test(intNumFinal(3), true)

local intNumFinalOrHi = intNumFinal + tp.createType(function(value)
  return value == 'hi'
end)

test(intNumFinalOrHi(), false)
test(intNumFinalOrHi('3'), false)
test(intNumFinalOrHi(-3), false)
test(intNumFinalOrHi(3), true)
test(intNumFinalOrHi('hi'), true)

local intNumFinalOrHi = (tp.createType(function(value)
  return type(value) == 'number'
end) * tp.createType(function(value)
  return value > 0
end)) + tp.createType(function(value)
  return value == 'hi'
end)

test(intNumFinalOrHi(), false)
test(intNumFinalOrHi('3'), false)
test(intNumFinalOrHi(-3), false)
test(intNumFinalOrHi(3), true)
test(intNumFinalOrHi('hi'), true)

local numOrStr = tp.defTypes.num + tp.createType(function(value)
  return type(value) == 'string'
end)

test(numOrStr(3), true)
test(numOrStr('3'), true)
test(numOrStr({}), false)

test(tp.defTypes.any(3), true)
test(tp.defTypes.any('hi!!'), true)

test(tp.defTypes.num(3), true)
test(tp.defTypes.num('hi!!'), false)

test(areError(function()
  tp({ value = 3, type = 333434 })
end), true)

local a = tp({ value = 3, type = tp.defTypes.num })
a:set(5)
test(a(), 5)
test(areError(function()
  a:set('55')
end), true)
test(a:safeset(23), true)
test(a:safeset('hiii'), false)
test(a:safeset(), false)
test(a(), 23)

local a = tp({ value = 3, type = function(value)
  return type(value) == 'number'
end })
a:set(5)
test(a(), 5)
test(areError(function()
  a:set('55')
end), true)
test(a:safeset(23), true)
test(a:safeset('hiii'), false)
test(a:safeset(), false)
test(a(), 23)

local testAValue = 0
local a = tp({ value = 3, type = tp.defTypes.num, set = function(self, value)
  testAValue = testAValue + 1
  return value + 10
end })
a:set(5)
test(a(), 15)
test(areError(function()
  a:set('55')
end), true)
test(a:safeset(23), true)
test(a:safeset('hiii'), false)
test(a:safeset(), false)
test(a(), 23 + 10)
test(testAValue, 2)

test(areError(function()
  local a = tp({ value = 10, type = tp.defTypes.str })
end), true)

local a = tp({ value = 'hello!', type = tp.defTypes.str, get = function(self)
  return self.value .. ' world'
end, set = function(self, value)
  return '123'
end })

test(a(), 'hello! world')
a:set(a())
test(a(), '123 world')

print('\nfailed tests: ', notOkTestCount)
