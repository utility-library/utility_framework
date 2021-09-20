local self = {
    translate = function(lang, text)
        if lang == "en" or text == "" then
            return text
        end

        local p = promise.new()

        PerformHttpRequest("https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl="..lang.."&dt=t&q="..text:gsub(" ", "+"), function(_, data)
            p:resolve(json.decode(data)[1][1][1]:gsub("+", " "))
        end)

        return Citizen.Await(p)
    end
}

return self