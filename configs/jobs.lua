Config.Jobs = {
    -- This is the primary job, if you want you can add the second or third one
    -- IS NOT EQUAL TO THE ESX JOBS TABLE (jobs are all dynamic so they don't need to be defined, this is like the gang or org/job_2)

    -- here you can configure the jobs, it is not a necessary thing, but if you want the ranks with all the names is indispensable
    -- you can also add custom parameters for any grade (you can get it with the GetJob)
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
        },
        ["police"] = {
            name = "Polizia",
            grades = {
                [1] = {
                    label  = "Recluta",
                    salary = 0,
                    boss   = false
                },
                [2] = {
                    label  = "Agente",
                    salary = 0,
                    boss   = false
                },
                [3] = {
                    label  = "Vice comandante",
                    salary = 0,
                    boss   = false
                },
                [3] = {
                    label  = "Comandante",
                    salary = 0,
                    boss   = false
                },
            }
        },
    },

    SalariesInterval = "5m", -- you can use: "s", "m" or "ms"
}