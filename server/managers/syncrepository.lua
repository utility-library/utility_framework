--- Check if a file or directory exists in this path
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
   return exists(path.."/")
end

function CheckForUpdates()
    local checkupdate = io.open("checkupdate.bat", "a")
    checkupdate:write([[
        @echo off
        for /r %%a in (.) do @if exist "%%a/.git" cmd /c "echo %%a && cd /d %%a && git pull"
        ]]..(Config.ResourcesUpdater.NeedUserInput and "pause" or "")..[[ 
        del "%~f0" & exit
    ]])
    checkupdate:close()

    os.execute("start checkupdate.bat")
end

if Config.ResourcesUpdater.SyncRemoteRepository then
    AddEventHandler("onResourceStart", function(res)
        Citizen.Wait(5)

        local repository = GetResourceMetadata(res, "repository", 0)

        if repository then
            repository = repository:gsub("%.git", "")
            local path = GetResourcePath(res)

            if not isdir(path.."/.git") then
                path = path:match("(resources//.*)")

                os.execute("cd "..path.." && git clone --bare "..repository..".git .git")
                os.execute("cd "..path.." && git init")
                Log("Building", "Reinitialized Git repository for "..res)
            end
        end
    end)
end