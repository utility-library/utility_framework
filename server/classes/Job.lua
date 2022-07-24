Job = class {
    name = "unknown",
    label = "unknown",
    onduty = true,
    grade = {
        id = 0,
        label = "unknown",
        salary = 0,
        boss = false,
    },

    __type = "Job",

    _Init = function(self)
        -- Check if the grade exist in the config and if so update the grade
        local JobConfig = Config.Jobs.Configuration[self.name]

        if JobConfig then
            if JobConfig.name then
                self.label = JobConfig.name
            end

            if type(self.onduty) ~= "boolean" then
                self.onduty = true
            end

            if JobConfig.grades and JobConfig.grades[self.grade.id] then
                -- Merge the grade id with the grade configuration
                self.grade = merge(
                    {id = self.grade.id}, 
                    clone(JobConfig.grades[self.grade.id])
                )
            end
        else
            self.grade = {
                id = 0,
                label = "unknown",
                salary = 0,
                boss = false,
            }
        end
    end
}