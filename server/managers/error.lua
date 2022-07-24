local AlreadyWarned = LoadResourceFile("utility_framework", "files/errors.utility")

if AlreadyWarned == nil then
    AlreadyWarned = {}
else
    AlreadyWarned = json.decode(AlreadyWarned)
end

Citizen.CreateThread(function()
    while true do
        local console = GetConsoleBuffer()

        for line in console:gmatch("[^\n]+") do
            if line:find("SCRIPT ERROR: @utility_framework") then
                local skip = false
                
                for i=1, #AlreadyWarned do
                    if AlreadyWarned[i] == line then
                        skip = true
                    end
                end
                
                if not skip then
                    table.insert(AlreadyWarned, line)
                    print("The ^4Utility Framework^0 has detected an ^1error^0 in the console. You can ^3report^0 the bug using the command ^3utility report^0")

                    SaveResourceFile("utility_framework", "files/errors.utility", json.encode(AlreadyWarned))
                end
            end
        end
        Citizen.Wait(5000)
    end
end)

RegisterCommand("testerror", function()
    if nil > 3 then

    end
end)