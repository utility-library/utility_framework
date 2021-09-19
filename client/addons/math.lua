local self = {
    humanize = function(number)
        local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

        int = int:reverse():gsub("(%d%d%d)", "%1,")
        return minus .. int:reverse():gsub("^,", "") .. fraction
    end,
    round = function(number, decimal)
        return math.floor((number * 10^decimal) + 0.5) / (10^decimal)
    end
}

return self