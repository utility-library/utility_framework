RemoveFromJob = function(job, source)
    if Utility.JobWorker[job] == nil then return end


    for i=1, #Utility.JobWorker[job] do
        if Utility.JobWorker[job][i] and Utility.JobWorker[job][i].id == source then
            table.remove(Utility.JobWorker[job], i)
        end
    end
end

AddToJob = function(job, type, source)
    --print("Adding "..source.." to "..job.name)

    if job then
        if Utility.JobWorker[job.name] == nil then Utility.JobWorker[job.name] = {} end

        table.insert(Utility.JobWorker[job.name], {
            id = source, 
            playername = GetPlayerName(source),
            type = type,
            label = job.label,
            name = job.name,
            onduty = job.onduty,
            grade = job.grade
        })
    end
end

GetPlayersWithJob = function(job)
    return Utility.JobWorker[job]
end
exports("GetPlayersWithJob", GetPlayersWithJob)

RegisterServerCallback("Utility:GetWorker", function(name)
    return Utility.JobWorker[name]
end)