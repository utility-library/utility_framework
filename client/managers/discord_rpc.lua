Citizen.CreateThread(function()
    local discord = Config.Addons.DiscordRPC

    SetDiscordAppId(discord.AppId)
    SetRichPresence(discord.Description)

    if discord.BigPicture.Key ~= "none" then
        SetDiscordRichPresenceAsset(discord.BigPicture.Key)
        SetDiscordRichPresenceAssetText(discord.BigPicture.Text)
    end

    if discord.SmallPicture.Key ~= "none" then
        SetDiscordRichPresenceAssetSmall(discord.SmallPicture.Key)
        SetDiscordRichPresenceAssetSmallText(discord.SmallPicture.Text)
    end

    local i=1
    for k,v in pairs(discord.Buttons) do
        SetDiscordRichPresenceAction(i, k, v)
        i=i+1
    end
end)