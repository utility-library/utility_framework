local function merge(...)
    local args = ({...})
	local merged = {}

	for i = 1, #args do
        for k,v in pairs(args[i]) do
            merged[k] = v
        end
	end
	return merged
end

function class(obj)
    obj.__type = "uClass"
    
    local class = {
        -- metamethods
		__add = obj.__add or obj._Add or nil,
		__sub = obj.__sub or obj._Sub or nil,
		__mul = obj.__mul or obj._Mul or nil,
		__div = obj.__div or obj._Div or nil,
		__idiv = obj.__idiv or obj._FloorDiv or nil,
		__mod = obj.__mod or obj._Mod or nil,
		__pow = obj.__pow or obj._Pow or nil,
		__unm = obj.__unm or obj._Neg or nil,
		__concat = obj.__concat or obj._Concat or nil,
		
		__len = obj.__len or obj._Len or obj.__len,
		
		__eq = obj.__eq or obj._IsEqual or nil,
		__lt = obj.__lt or obj._IsLessThan or nil,
		__le = obj.__le or obj._IsLessOrEqual or nil,
		
		__band = obj.__band or obj._And or nil,
		__bor = obj.__bor or obj._Or or nil,
		__bxor = obj.__bxor or obj._Xor or nil,
		__bnot = obj.__bnot or obj._Not or nil,
		
		__shl = obj.__shl or obj._LShift or nil,
		__shr = obj.__shr or obj._RShift or nil,
		
		__call = obj.__call or obj._Call or nil,
    }

	return function(options)
        local class = setmetatable(options and merge(obj, options) or obj, class)

        if class._Init then
            class:_Init()
        end

        return class
    end
end

function extend(class, extension)
    if type(class) ~= 'function' then
        error("Cant extend a non uClass object")
	end
    
	return function(options)
	    local a = class()
	    
        local class = setmetatable(options and merge(options, extension, a) or merge(extension, a), a)

        if class._Init then
            class:_Init()
        end

        return class
    end
end

_TYPE = type
function type(obj)	
    if _TYPE(obj) == 'table' and obj.__type then
        return obj.__type
    else
        return _TYPE(obj)
    end
end


--[[
    Player = class {
        money = 100
    }

    ExtendedPlayer = extend(Player, {
        bank = 200
    })



    local myPlayer = Player()
    local myExtendedPlayer = ExtendedPlayer()

    print(myPlayer.money, myPlayer.bank)
    print(myExtendedPlayer.money, myExtendedPlayer.bank)

    -- Output
    100	nil
    100	200
]]