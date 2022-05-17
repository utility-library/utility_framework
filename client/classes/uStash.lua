GetStash = function(identifier)
    return NewCustomStateBag("stash:"..identifier, true)
end

exports("GetStash", GetStash)