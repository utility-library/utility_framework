return {
    Text = function(coords, text)
        local active = true
            
        if type(coords) == "table" then
            Citizen.CreateThread(function()
                while active do
                    DrawText2D(coords.x, coords.y, text)
                    Citizen.Wait(1)
                end
            end)
        elseif type(coords) == "vector3" then
            Citizen.CreateThread(function()
                while active do
                    DrawText3D(coords.x, coords.y, coords.z, text)
                    Citizen.Wait(1)
                end
            end)
        elseif IsAnEntity(coords) then
            Citizen.CreateThread(function()
                while active do
                    DrawText3D(GetEntityCoords(coords), text)
                    Citizen.Wait(1)
                end
            end)
        end
    
        return {
            Stop = function()
                active = false
            end
        }
    end,
    
    Line = function(start, _end, r,g,b,a)
        r = r or 0
        g = g or 113
        b = b or 255
        a = a or 255

        local active = true
        local isEntityStart = IsAnEntity(start)
        local isEntityEnd = IsAnEntity(_end)
    
        if isEntityStart or isEntityEnd then
            Citizen.CreateThread(function()
                while active do
                    if isEntityStart then start = GetEntityCoords(start) end
                    if isEntityEnd then _end = GetEntityCoords(_end) end
    
                    DrawLine(start, _end, r,g,b,a)
                    Citizen.Wait(1)
                end
            end)
        elseif type(start) == "vector3" then
            Citizen.CreateThread(function()
                while active do
                    DrawLine(start, _end, r,g,b,a)
                    Citizen.Wait(1)
                end
            end)
        end
    
        return {
            Stop = function()
                active = false
            end
        }
    end,
    
    Sphere = function(coords, radius, r,g,b,a)
        r = r or 0
        g = g or 113
        b = b or 255
        a = a or 255

        local active = true
    
        if type(coords) == "vector3" then
            Citizen.CreateThread(function()
                while active do
                    DrawSphere(coords.x, coords.y, coords.z, radius, r,g,b,a)
                    Citizen.Wait(1)
                end
            end)
        elseif IsAnEntity(coords) then
            Citizen.CreateThread(function()
                while active do
                    DrawSphere(GetEntityCoords(coords), radius, r,g,b,a)
                    Citizen.Wait(1)
                end
            end)
        end
    
        return {
            Stop = function()
                active = false
            end
        }
    end
}