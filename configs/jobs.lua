Config.Jobs = {
    -- This is the primary job, if you want you can add the second or third one
    -- IS NOT EQUAL TO THE ESX JOBS TABLE (jobs are all dynamic so they don't need to be defined, this is like the gang or org/job_2)

    -- here you can configure the jobs, it is not a necessary thing, but if you want the ranks with all the names is indispensable
    Configuration = {
        ["unemployed"] = {
            name = "Unemployed",
            grades = {
                [1] = {
                    label  = "Looking for job",
                    salary = 0,
                    boss   = false
                },
            }
        }
    },

    SalariesInterval = "5m", -- you can use: "s", "m" or "ms"
}