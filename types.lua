local function createType(fun)
  assert(type(fun) == 'function', 'need function and not a ' .. type(fun))
  return setmetatable({ callback = fun },
    {
      __call = function(self, value)
        return self.callback(value)
      end,
      __add = function(a, b)
        return createType(function(value)
          return a(value) or b(value)
        end)
      end,
      __mul = function(a, b)
        return createType(function(value)
          return a(value) and b(value)
        end)
      end
    })
end

local defTypes = {}
defTypes.any = createType(function() return true end)
defTypes.num = createType(function(value) return type(value) == 'number' end)
defTypes.str = createType(function(value) return type(value) == 'string' end)
defTypes.bool = createType(function(value) return type(value) == 'boolean' end)
defTypes.func = createType(function(value) return type(value) == 'function' end)
defTypes.tab = createType(function(value) return type(value) == 'table' end)
defTypes.none = createType(function(value) return type(value) == 'nil' end)
defTypes.thread = createType(function(value) return type(value) == 'thread' end)
defTypes.userdata = createType(function(value) return type(value) == 'userdata' end)
defTypes.cdata = createType(function(value) return type(value) == 'cdata' end)

return setmetatable({ createType = createType, defTypes = defTypes }, { __call = function(self, argv)
  if type(argv) == 'nil' then
    argv = {}
  end
  assert(type(argv) == 'table', 'need argv table, not a ' .. type(argv))

  local t = {}

  t.value = argv.value

  if argv.type then
    if type(argv.type) == 'table' then
      t.type = argv.type
    elseif type(argv.type) == 'function' then
      t.type = createType(argv.type)
    else
      error('need type or callback function to create it')
    end
  else
    t.type = defTypes.any
  end

  if argv.get then
    assert(type(argv.get) == 'function', 'need function and not a ' .. type(argv.get))
    t.get = argv.get
  else
    t.get = function(self)
      return self.value
    end
  end

  t.safeset = function(self, value)
    if self.type(value) then
      self.value = value
      return true
    else
      return false
    end
  end

  if argv.set then
    assert(type(argv.set) == 'function', 'need function and not a ' .. type(argv.set))
    local plainSafeset = t.safeset
    local setter = argv.set
    t.safeset = function(self, value)
      if self.type(value) then
        value = setter(self, value)
        return plainSafeset(self, value)
      else
        return false
      end
    end
  end

  t.set = function(self, value)
    if not self:safeset(value) then
      error("can't set value " .. tostring(value) .. ', wrong type')
    end
  end

  if not t.type(t.value) then
    error("can't init value " .. tostring(t.value) .. ', wrong type')
  end

  return setmetatable(t, { __call = t.get })
end })
