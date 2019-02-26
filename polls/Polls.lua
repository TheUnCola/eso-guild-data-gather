GPPolls = ZO_CallbackObject:Subclass()

function GPPolls:New(saveData)
    local storage = ZO_CallbackObject.New(self)
    storage.polls = saveData.polls or {}
    saveData.polls = storage.polls
    return storage
end

function GPPolls:Finalize()
end

function GPPolls:GetPolls()
    return self.polls
end

function GPPolls:GetKeys()
    local keys = {}
    for key in pairs(self.polls) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    return keys
end

function GPPolls:GetPoll(key)
    return self.polls[key]
end

function GPPolls:HasPoll(key)
    return self.polls[key] ~= nil
end

function GPPolls:HasPolls()
    return next(self.polls) ~= nil
end

function GPPolls:SetPoll(key, member)
    local keyExists = self:HasPoll(key)
    self.polls[key] = member
    if (not keyExists) then
        self:FireCallbacks("OnKeysUpdated")
    end
end

function GPPolls:DeletePoll(key)
    local keyExists = self:HasPoll(key)
    self.polls[key] = nil
    if (keyExists) then
        self:FireCallbacks("OnKeysUpdated")
    end
end

function GPPolls:DeleteAllPolls()
    local hasPolls = self:HasPolls()
    ZO_ClearTable(self.polls)
    if (hasPolls) then
        self:FireCallbacks("OnKeysUpdated")
    end
end

function GPPolls:GetDataForPoll(key)
    local poll = self:GetPoll(key)
    local data = poll.data
    return data
end

function GPPolls:SetDataForPoll(key, items)
    local poll = self:GetPoll(key)
    poll.items = items
    self:FireCallbacks("OnKeysUpdated")
    return poll
end

function GPPolls:NewPoll(name, displayName)
    name = zo_strformat(SI_UNIT_NAME, name)
    local newPoll = {
        bestItem = {itemLink = "", value = 0},
        totalValue = 0,
        items = {},
        displayName = displayName
    }
    self:FireCallbacks("OnKeysUpdated")
    return newPoll
end
