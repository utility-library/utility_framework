local loaded = {}
local jobs

local self = {
    set = function(_, name)
        jobs = name
    end,
    loaded = loaded
}

function JobChange(old, new, type)
    for i=1, #jobs do
        if new.name == jobs[i] then -- if the new job is a job in the list
            if not loaded[i] then
                loaded[i] = true
                if LoadJob then LoadJob(jobs[i], type) end
            end
        else -- if the new job is not in the list of the jobs
            if loaded[i] then -- unload all the jobs
                loaded[i] = false
                if UnLoadJob then UnLoadJob(jobs[i], type) end
            end
        end
    end
end

function OnDuty(duty)
    for i=1, #jobs do
        for j=1, #uPlayer.jobs do
            if uPlayer.jobs[j].name == jobs[i] then -- if the current job is a job in the list
                if duty then
                    if LoadJob then LoadJob(jobs[i], j) end
                else
                    if UnLoadJob then UnLoadJob(jobs[i], j) end
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while not Loaded do
        Citizen.Wait(50)
    end

    if LoadJob then
        for i=1, #jobs do
            for j=1, #uPlayer.jobs do
                if uPlayer.jobs[j].name == jobs[i] then
                    loaded[i] = true
                    LoadJob(jobs[i], j)
                end
            end
        end
    end
end)

return self