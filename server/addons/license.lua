local function capture(input)
    local cmd = io.popen(input, 'r')
    local output = cmd:read('*a')
    cmd:close()
    return output
end

local self = {
    get = function(url, cb)
        local a = os.clock()
        local output = capture('curl -i "'..url..'"')
        local b = os.clock()
        local info = {}

        local index = 1
        local _, maxindex = output:gsub('\n', '\n')
        for line in output:gmatch("([^\n]*)\n?") do
            if index == 1 then
                info.status = line:sub(10)
            elseif line:find("Connection") then
                info.connection = line:sub(13)
            elseif index-1 == maxindex then
                output = line
            end

            index = index + 1
        end

        info.resolve_time = tonumber(string.format("%.0f", (b-a)*1000))

        if cb then
            cb(output, info)
        else
            return output, info
        end
    end
}

return self