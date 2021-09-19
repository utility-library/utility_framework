local cpuSeconds = 0
local self = {
    start = function()
        cpuSeconds = os.clock()
    end,
    finish = function()
        return (os.clock()-cpuSeconds)*1000 -- Ms
    end
}

return self