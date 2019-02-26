local RELEASE_COUNT = 3

local listContainer
local polls = {}
local saveData = {}
local Settings

GPPollList = ZO_Object:Subclass()
function GPPollList:New()
    local obj = ZO_Object.New(self)
    self:Initialize()
    return obj
end

function GPPollList:Initialize()
    saveData = ZO_SavedVars:New("GPPollList_db", RELEASE_COUNT, nil, {members = {}})
    GuildPoll.Modules.Polls = GPPolls:New(saveData)
    polls = GuildPoll.Modules.Polls
    
    listContainer = GPPollsWindow:GetNamedChild("List")
    
    GPPollsWindow:ClearAnchors()
    Settings = GuildPoll.Settings
    GPPollsWindow:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        Settings:Window().positionLeft,
        Settings:Window().positionTop
    )
    GPPollsWindow:SetDimensions(Settings:Window().width, Settings:Window().height)
    GPPollsWindow:SetHandler("OnResizeStop", function(...)self:WindowResizeHandler(...) end)
    GPPollsWindow.onResize = self.onResize
    
    GPPollList:SetWindowTransparency()
    GPPollList:SetWindowBackgroundTransparency()
    
    self:AddAllGroupMembers()
    self:SetupScrollList()
    self:UpdateScrollList()
    
    if (Settings.Status() == Settings.TRACKING_STATUS.ENABLED) then
        self:AddEventHandlers()
    end
    
    polls:RegisterCallback("OnKeysUpdated", self.UpdateScrollList)
end

-- I should handle this with callbacks from the settings, if possible
function GPPollList:AddEventHandlers()
    Settings:ToggleStatusValue(Settings.TRACKING_STATUS.ENABLED)
end

function GPPollList:RemoveEventHandlers()
    Settings:ToggleStatusValue(Settings.TRACKING_STATUS.DISABLED)
end

function GPPollList:Finalize()
    local _, _, _, _, offsetX, offsetY = GPPollsWindow:GetAnchor(0)
    
    Settings:Window().positionLeft = GPPollsWindow:GetLeft()
    Settings:Window().positionTop = GPPollsWindow:GetTop()
    Settings:Window().width = GPPollsWindow:GetWidth()
    Settings:Window().height = GPPollsWindow:GetHeight()
    saveData.members = polls:GetCleanMembers()
end

function GPPollList:GetWindowTransparency()
    return Settings:Window().transparency
end

function GPPollList:SetWindowTransparency(value)
    if value ~= nil then
        Settings:Window().transparency = value
    end
    GPPollsWindow:SetAlpha(Settings:Window().transparency / 100)
end

function GPPollList:SetWindowBackgroundTransparency(value)
    if value ~= nil then
        Settings:Window().backgroundTransparency = value
    end
    GPPollsWindow:GetNamedChild("BG"):SetAlpha(Settings:Window().backgroundTransparency / 100)
end

function GPPollList:WindowResizeHandler(control)
    local width, height = control:GetDimensions()
    Settings:Window().width = width
    Settings:Window().height = height
    
    local scrollData = ZO_ScrollList_GetDataList(listContainer)
    ZO_ScrollList_Commit(listContainer)
end

function GPPollList:SetupScrollList()
    ZO_ScrollList_AddResizeOnScreenResize(listContainer)
    ZO_ScrollList_AddDataType(
        listContainer,
        GuildPoll.DataTypes.MEMBER,
        "GuildPollDataRow",
        20,
        function(listControl, data)
            self:SetupMemberRow(listControl, data)
        end
)
end

function GPPollList:UpdateScrollList()
    local scrollData = ZO_ScrollList_GetDataList(listContainer)
    ZO_ScrollList_Clear(listContainer)
    
    local memberKeys = polls:GetKeys()
    local memberList = polls:GetMembers()
    local memberArray = {}
    for i = 1, #memberKeys do
        local mem = polls:GetMember(memberKeys[i])
        mem.id = memberKeys[i]
        memberArray[#memberArray + 1] = mem
    end
    table.sort(memberArray, function(a, b)
        if (a.totalValue == b.totalValue) then
            return a.displayName < b.displayName
        end
        return a.totalValue > b.totalValue
    end)
    for i = 1, #memberArray do
        scrollData[#scrollData + 1] =
            ZO_ScrollList_CreateDataEntry(GuildPoll.DataTypes.MEMBER, { rawData = memberArray[i]})
    end
    
    ZO_ScrollList_Commit(listContainer)
end

function GPPollList:SetupMemberRow(rowControl, rowData)
    rowControl.data = rowData
    local data = rowData.rawData
    local memberId = GetControl(rowControl, "FarmerId")
    local memberName = GetControl(rowControl, "Farmer")
    local bestItem = GetControl(rowControl, "BestItemName")
    local totalValue = GetControl(rowControl, "TotalValue")
    
    memberId:SetText(data.id)
    memberName:SetText(data.displayName)
    bestItem:SetText(data.bestItem.itemLink)
    totalValue:SetText(GuildPoll.FormatNumber(data.totalValue, 2) .. 'g')
end

function GPPollList.onResize()
    ZO_ScrollList_Commit(listContainer)
end

function GPPollList:ToggleMembersWindow()
    FarmingPartyMembersWindow:SetHidden(not FarmingPartyMembersWindow:IsHidden())
end

function GPPollList:Reset()
    polls:DeleteAllMembers()
    self:AddAllGroupMembers()
end

function GPPollList:GetAllGroupMembers()
    local countMembers = GetGroupSize()
    local rawMembers = {}
    rawMembers[GetUnitName("player")] = UndecorateDisplayName(GetDisplayName("player"))
    -- Get list of member names in current group
    for i = 1, countMembers do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local name = zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag))
            if (name ~= playerName) then
                rawMembers[name] = UndecorateDisplayName(GetUnitDisplayName(unitTag))
            end
        end
    end
    return rawMembers
end

function GPPollList:RemoveMissingMembers(currentGroupMembers)
    local savedMembers = polls:GetMembers()
    for name, displayName in pairs(savedMembers) do
        if currentGroupMembers[name] == nil then
            polls:DeleteMember(name)
        end
    end
end

function GPPollList:PruneMissingMembers()
    local membersInGroup = self:GetAllGroupMembers()
    self:RemoveMissingMembers(membersInGroup)
end

function GPPollList:AddAllGroupMembers()
    local membersInGroup = self:GetAllGroupMembers()
    
    -- Add all missing members
    for name, displayName in pairs(membersInGroup) do
        if not polls:HasMember(name) then
            local newMember = polls:NewMember(name, displayName)
            polls:SetMember(name, newMember)
        end
    end
end

function GPPollList:ShowAllGroupMembers()
    d(polls)
    local player = polls:GetMember(GetUnitName("player"))
    d("Total value: " .. tostring(player.totalValue))
end

function GPPollList:PrintScoresToChat()
    local topScorers = 'FARMING SCORES: '
    local array = {}
    local groupMembers = polls:GetKeys()
    for i = 1, #groupMembers do
        local member = polls:GetMember(groupMembers[i])
        local scoreData = {name = groupMembers[i], totalValue = member.totalValue, displayName = member.displayName}
        array[#array + 1] = scoreData
    end
    table.sort(array, function(a, b) return a.totalValue > b.totalValue end)
    for i = 1, #array do
        topScorers = topScorers .. array[i].displayName .. ': ' .. GuildPoll.FormatNumber(array[i].totalValue, 2) .. 'g. '
    end
    ZO_ChatWindowTextEntryEditBox:SetText(topScorers)
end
