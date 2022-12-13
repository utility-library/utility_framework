_RegisterNUICallback = RegisterNUICallback
RegisterNUICallback = function(name, cb)
    _RegisterNUICallback(name, function(data, _cb)
        cb(data)
        _cb("")
    end)
end

local CurrentMenu = {}
local CurrentDialog = {}

-- Functions
    ConvertColors = function(input)
        -- convert from "{red: test}" to "<span style='color: red'> test</span>"
        -- see https://developer.roblox.com/en-us/articles/string-patterns-reference to learn more

        for color, text in input:gmatch("{([%a%d%p]+):([%w%s]+)}") do
            input = input:gsub(
                "{"..color..":"..text.."}", 
                "<span style='color: "..color.."'>"..text.."</span>"
            )
        end

        return input
    end

    EmitCb = function(id)
        if id == "back" then -- on back clicked call the close function
            CurrentMenu.close()
        else
            CurrentMenu.cb(CurrentMenu.menu[id], Menu)
        end
    end

-- Exports
    CreateMenu = function(title, menu, cb, close)
        SetCursorLocation(0.1, 0.5)
        return Menu({
            title = title,
            menu = menu,
            cb = cb,
            close = close
        })
    end

    CreateDialog = function(title, description, inputs, cb, close)
        return Dialog({
            title = title,
            description = description,
            inputs = inputs,
            cb = cb,
            close = close
        })
    end

    Close = function(type)
        if type == "menu" then
            CurrentMenu:close()
        elseif type == "dialog" then
            CurrentDialog:close() 
        else
            if CurrentMenu then
                CurrentMenu:close()
            end
            if CurrentDialog then
                CurrentDialog:close()
            end
        end
    end

-- Classes
    Menu = class {
        open = function(self)
            CurrentMenu = self
    
            SendNUIMessage({
                zone = "menu",
                type = "setMenu",
                title = self.title,
                menu = self.menu
            })
            SetNuiFocus(true, true)
            self:visibility(true)
        end,

        visibility = function(self, show)
            SendNUIMessage({
                zone = "menu",
                type = "visibility",
                show = show
            })
        end,

        emit = function(self, id)
            if id == "back" then -- on back clicked call the close function
                self:close()
            else
                self:cb(self.menu[id])
            end
        end,

        _Init = function(self)
            self.title = ConvertColors(self.title) -- convert to html color

            local _close = self.close
            self.close = function(self)
                if _close then
                    _close(self)
                end

                if not self._preventDefault then
                    CurrentMenu = nil
                    SetNuiFocus(false, false)
                    self:visibility(false)
                end
            end

            -- same for every text in the menu content
            for i=1, #self.menu do
                self.menu[i].text = ConvertColors(self.menu[i].text)
            end
    
            -- open the menu
            self:open()
        end,

        sub = function(self, title, menu, cb, close)
            local ParentMenu = CurrentMenu
            
            CreateMenu(title, menu, cb, function(self)    
                -- reopen the parent
                ParentMenu:open()
            end)
        end,

        preventDefault = function()
            self._preventDefault = true
        end,

        update = function(self, title, menu)
            self.menu = menu
            self.title = ConvertColors(title) -- convert to html color

            for i=1, #self.menu do
                self.menu[i].text = ConvertColors(self.menu[i].text)
            end

            self:open()
        end
    }

    Dialog = class {
        open = function(self)
            CurrentDialog = self

            SendNUIMessage({
                zone = "dialog",
                type = "setDialog",
                dialog = self.dialog,
            })
            self:visibility(true)
        end,

        visibility = function(self, show)
            if CurrentMenu == nil then
                SetNuiFocus(show, show)
            end

            SendNUIMessage({
                zone = "dialog",
                type = "visibility",
                show = show
            })
        end,

        emit = function(self, id, data)
            if id == "dialog:cancel" then -- on back clicked call the close function
                self:close()
            else
                self:cb(data.inputs)

                if not self.preventDefault then
                    self:visibility(false)
                end
            end
        end,

        _Init = function(self)
            self.title = ConvertColors(self.title) -- convert to html color
            self.description = ConvertColors(self.description) -- convert to html color

            -- same for every name in the inputs
            for i=1, #self.inputs do
                self.inputs[i].name = ConvertColors(self.inputs[i].name)
            end
    
            local _close = self.close
            self.close = function(self)
                if _close then
                    _close(self)
                end

                if not self.preventDefault then
                    CurrentDialog = nil
                    self:visibility(false)
                end
            end

            self.dialog = {
                title = self.title,
                description = self.description,
                inputs = self.inputs
            }
            -- open the menu
            self:open()
        end,

        update = function(self, title, description, inputs)
            self.title = ConvertColors(self.title) -- convert to html color
            self.description = ConvertColors(self.description) -- convert to html color

            -- same for every name in the inputs
            for i=1, #self.inputs do
                self.inputs[i].name = ConvertColors(self.inputs[i].name)
            end

            self.dialog = {
                title = self.title,
                description = self.description,
                inputs = self.inputs
            }

            self:open()
        end
    }

-- Nui
    RegisterNUICallback("dialog:cancel", function(data)
        CurrentDialog:emit("dialog:cancel", data)
    end)
    RegisterNUICallback("dialog:done", function(data)
        CurrentDialog:emit("dialog:done", data)
    end)

    RegisterNUICallback("click", function(data)
        CurrentMenu:emit(data.id)
    end)
    RegisterNUICallback("slider", function(data)
        CurrentMenu.menu[data.id].count = data.value -- update the current count

        CurrentMenu:emit(data.id)
    end)

    exports("CreateMenu", CreateMenu)
    exports("CreateDialog", CreateDialog)
    exports("Close", Close)