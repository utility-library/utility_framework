RemoveFromJob = function(job, source)
    if Utility.JobWorker[job] == nil then return end


    for i=1, #Utility.JobWorker[job] do
        if Utility.JobWorker[job][i] == source then
            table.remove(Utility.JobWorker[job], i)
        end
    end
end

AddToJob = function(job, source)
    if job then
        if Utility.JobWorker[job] == nil then Utility.JobWorker[job] = {} end

        table.insert(Utility.JobWorker[job], source)
    end
end

GetPlayersWithJob = function(job)
    return Utility.JobWorker[job]
end
exports("GetPlayersWithJob", GetPlayersWithJob)