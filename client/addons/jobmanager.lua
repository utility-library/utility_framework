local loaded = false
local job

local self = {
    set = function(_, name)
        job = name
    end,
    loaded = loaded
}

function JobChange(old, new)
    if new[1].name == job then
        if not loaded then
            loaded = true
            if LoadJob then
                LoadJob()
            end
        end
    else
        if loaded then
            loaded = false
            if UnLoadJob then
                UnLoadJob()
            end
        end
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(500)

    if uPlayer.jobs[1].name == job then
        loaded = true
        if LoadJob then
            LoadJob()
        end
    end
end)

return self