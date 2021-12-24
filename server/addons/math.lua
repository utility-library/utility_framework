local self = {
    humanize = function(number)
        local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

        int = int:reverse():gsub("(%d%d%d)", "%1,")
        return minus .. int:reverse():gsub("^,", "") .. fraction
    end,
    round = function(number, decimal)
        return math.floor((number * 10^decimal) + 0.5) / (10^decimal)
    end,
    random = function(length)
        local finalNumber = ""
        for i=1, length do
            finalNumber = finalNumber..math.random(0, 9)
        end

        return tonumber(finalNumber)
    end,
    randoms = function(length, number)
        local alphabet = ""
        if number then
            alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        else
            alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        end
        
        local _string = ""

        for i=1, length do
            local rand = math.random(1, alphabet:len())

            _string = _string..alphabet:sub(rand, rand)
        end
        
        return _string
    end
}

return self