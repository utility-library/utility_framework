local loaded = {}
local job

local self = {
    set = function(_, name)
        job = name
    end,
    loaded = loaded
}

function JobChange(old, new, type)
    if type == 1 then
        for i=1, #job do
            if new.name == job[i] then
                if not loaded[i] then
                    loaded[i] = true
                    if LoadJob then
                        LoadJob(job[i])
                    end
                end
            else
                if loaded[i] then
                    loaded[i] = false
                    if UnLoadJob then
                        UnLoadJob(job[i])
                    end
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(500)
    while uPlayer == nil do
        Citizen.Wait(1)
    end

    for i=1, #job do
        --print(uPlayer.jobs[1].name, job[i])
        if uPlayer.jobs[1].name == job[i] then
            --print("Have job")
            loaded[i] = true
            if LoadJob then
                LoadJob(job[i])
            end
        end
    end
end)

return self