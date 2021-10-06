local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function NumberToBin(x)
	local binary = ""

	while x~=1 and x~=0 do
		binary=tostring(x%2)..binary
		x=math.modf(x/2)
	end
	binary=tostring(x)..binary
    
	return binary
end

local self = {
    -- Base 64
    B64ToUtf8 = function(_b64)
        _b64 = string.gsub(_b64, '[^'..b64..'=]', '')
        return (_b64:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b64:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
                return string.char(c)
        end))
    end,
    Utf8ToB64 = function(utf8)
        return ((utf8:gsub('.', function(x) 
            local r,b64='',x:byte()
            for i=8,1,-1 do r=r..(b64%2^i-b64%2^(i-1)>0 and '1' or '0') end
            return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b64:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#utf8%3+1])
    end,
    -- Hex
    Utf8ToHex = function(utf8)
        return tostring(utf8):gsub('.', function(c) 
            return string.format('%02X', string.byte(c)) 
        end)
    end,
    HexToUtf8 = function(hex)
        return tostring(hex):gsub('..', function(c) 
            return string.char(tonumber(c, 16))
        end)
    end,
    -- Binary
    Utf8ToBin = function(utf8)
        return tostring(utf8):gsub('.', function(c) 
            return NumberToBin(c:byte()).." "
        end)
    end,
    BinToUtf8 = function(bin)
        local _ = ""
        for word in bin:gmatch("%S+") do 
            _ = _..string.char(tonumber(word, 2))
        end
        return _
    end,
    -- Sha
    Utf8ToSHA = function(utf8)
        local Key53 = math.random(1, 9999999999)
        local Key14 = math.random(1, 9999)
      
        local inv256

        if not inv256 then
            inv256 = {}
            for M = 0, 127 do
                local inv = -1
                repeat inv = inv + 2
                until inv * (2*M + 1) % 256 == 1
                inv256[M] = inv
            end
        end
        
        local K, F = Key53, 16384 + Key14

        return (utf8:gsub('.', function(m)
            local L = K % 274877906944
            local H = (K - L) / 274877906944
            local M = H % 128
            m = m:byte()
            local c = (m * inv256[M] - (H - M) / 128) % 256
            K = L * F + H + c + m
            return ('%02x'):format(c)
        end)), Key53.." "..Key14
    end,
    ShaToUtf8 = function(encrypted, key)
        local Key53, Key14 = nil, nil
        if key == nil or key == "nil" then return nil end

        for Key in key:gmatch("%w+") do 

            if not Key53 then
                Key53 = tonumber(Key)
            else
                Key14 = tonumber(Key)
            end
        end

        local K, F = Key53, 16384 + Key14
        
        return encrypted:gsub('%x%x', function(c)
            c = tonumber(c, 16)

            local L = K % 274877906944  -- 2^38
            local H = (K - L) / 274877906944
            local M = H % 128
            local m = (c + (H - M) / 128) * (2*M + 1) % 256

            K = L * F + H + c + m
            return string.char(m)
        end)
    end
}

return self