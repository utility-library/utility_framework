local DiscordEnv = {
    client = {},
    endpoints = {
        CHANNEL                       = "/channels/%s",
        CHANNEL_INVITES               = "/channels/%s/invites",
        CHANNEL_MESSAGE               = "/channels/%s/messages/%s",
        CHANNEL_MESSAGES              = "/channels/%s/messages",
        CHANNEL_MESSAGES_BULK_DELETE  = "/channels/%s/messages/bulk-delete",
        CHANNEL_MESSAGE_REACTION      = "/channels/%s/messages/%s/reactions/%s",
        CHANNEL_MESSAGE_REACTIONS     = "/channels/%s/messages/%s/reactions",
        CHANNEL_MESSAGE_REACTION_ME   = "/channels/%s/messages/%s/reactions/%s/@me",
        CHANNEL_MESSAGE_REACTION_USER = "/channels/%s/messages/%s/reactions/%s/%s",
        CHANNEL_PERMISSION            = "/channels/%s/permissions/%s",
        CHANNEL_PIN                   = "/channels/%s/pins/%s",
        CHANNEL_PINS                  = "/channels/%s/pins",
        CHANNEL_RECIPIENT             = "/channels/%s/recipients/%s",
        CHANNEL_TYPING                = "/channels/%s/typing",
        CHANNEL_WEBHOOKS              = "/channels/%s/webhooks",
        GATEWAY                       = "/gateway",
        GATEWAY_BOT                   = "/gateway/bot",
        GUILD                         = "/guilds/%s",
        GUILDS                        = "/guilds",
        GUILD_AUDIT_LOGS              = "/guilds/%s/audit-logs",
        GUILD_BAN                     = "/guilds/%s/bans/%s",
        GUILD_BANS                    = "/guilds/%s/bans",
        GUILD_CHANNELS                = "/guilds/%s/channels",
        GUILD_EMBED                   = "/guilds/%s/embed",
        GUILD_EMOJI                   = "/guilds/%s/emojis/%s",
        GUILD_EMOJIS                  = "/guilds/%s/emojis",
        GUILD_INTEGRATION             = "/guilds/%s/integrations/%s",
        GUILD_INTEGRATIONS            = "/guilds/%s/integrations",
        GUILD_INTEGRATION_SYNC        = "/guilds/%s/integrations/%s/sync",
        GUILD_INVITES                 = "/guilds/%s/invites",
        GUILD_MEMBER                  = "/guilds/%s/members/%s",
        GUILD_MEMBERS                 = "/guilds/%s/members",
        GUILD_MEMBER_ME_NICK          = "/guilds/%s/members/@me/nick",
        GUILD_MEMBER_ROLE             = "/guilds/%s/members/%s/roles/%s",
        GUILD_PRUNE                   = "/guilds/%s/prune",
        GUILD_REGIONS                 = "/guilds/%s/regions",
        GUILD_ROLE                    = "/guilds/%s/roles/%s",
        GUILD_ROLES                   = "/guilds/%s/roles",
        GUILD_WEBHOOKS                = "/guilds/%s/webhooks",
        INVITE                        = "/invites/%s",
        OAUTH2_APPLICATION_ME         = "/oauth2/applications/@me",
        USER                          = "/users/%s",
        USER_ME                       = "/users/@me",
        USER_ME_CHANNELS              = "/users/@me/channels",
        USER_ME_CONNECTIONS           = "/users/@me/connections",
        USER_ME_GUILD                 = "/users/@me/guilds/%s",
        USER_ME_GUILDS                = "/users/@me/guilds",
        VOICE_REGIONS                 = "/voice/regions",
        WEBHOOK                       = "/webhooks/%s",
        WEBHOOK_TOKEN                 = "/webhooks/%s/%s",
        WEBHOOK_TOKEN_GITHUB          = "/webhooks/%s/%s/github",
        WEBHOOK_TOKEN_SLACK           = "/webhooks/%s/%s/slack",
    },
    on = {
        ["ready"] = {},
        ["botmsg"] = {}
    }
}

DiscordEnv.emit = function(type, ...)
    for i=1, #DiscordEnv.on[type] do
        DiscordEnv.on[type][i](...)
    end
end

local http = addon("http")
local format = string.format

function DiscordApiRequest(method, endpoint, jsondata)
    local jsondata = jsondata or ""
    local header = {
        ["Content-Type"] = "application/json", 
        ["Authorization"] = DiscordEnv.TOKEN
    }
    local p = nil
    --print(method, jsondata, json.encode(header))

    if method == "PUT" or method == "PATCH" or method == "POST" then
        header["Accept"] = "application/json"

        jsondata = jsondata and json.encode(jsondata) or "{}"
        jsondata = json.encode(jsondata)

        http.post("https://discord.com/api/v7"..endpoint, function(data, info)
            DiscordEnv.emit("botmsg", json.decode(data))
            p = {data = data, info = info}
        end, jsondata, header)
    else
        PerformHttpRequest("https://discord.com/api/v7"..endpoint, function(errorCode, resultData, resultHeaders)
            p = {
                data    = resultData, 
                code    = errorCode,
                header  = resultHeaders
            }
        end, method, jsondata, header)
    end

    while p == nil do
        Citizen.Wait(1)
    end

    return p
end

function tabconcat(table1, table2)
    for k, v in pairs(table2) do
        table1[k] = v
    end

    return table1
end

function PopulateChannel(self, channel_id)
    self.channel_id = channel_id

    self.send = function(self, msg)
        if type(msg) == "string" then
            local data = DiscordApiRequest("POST", format(DiscordEnv.endpoints.CHANNEL_MESSAGES, self.channel_id), {
                content = msg
            })
            return json.decode(data.data)
        end

    end

    return self
end

local botFunctions = {
    getChannel = function(channel_id)
        local data = DiscordApiRequest("GET", format(DiscordEnv.endpoints.CHANNEL, channel_id))
        
        local self = json.decode(data.data)
        self.__index = self
        self = PopulateChannel(self, channel_id)

        return setmetatable({}, self)
    end
}

local self = {
    webhook = function(webhook, options)
        PerformHttpRequest("https://discord.com/api/webhooks/"..webhook, function(err, text, headers) end, 
        'POST', json.encode(options), { ['Content-Type'] = 'application/json' })
    end,

    client = function()
        local clientTable = botFunctions
        DiscordEnv.client = clientTable

        return clientTable
    end,

    login = function(token)
        DiscordEnv.TOKEN = "Bot "..token
        local data = DiscordApiRequest("GET", DiscordEnv.endpoints.USER_ME)

        -- Update the client data
        DiscordEnv.client = tabconcat(DiscordEnv.client, json.decode(data.data))

        DiscordEnv.emit("ready", json.decode(data.data))
    end,

    once = function(type, cb, data)
        if DiscordEnv.on[type] then
            if type == "msg" then
                -- To Do
            else
                table.insert(DiscordEnv.on[type], cb) 
            end
        end
    end
}

return self