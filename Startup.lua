local ADDON_NAME = "GuildPoll"

GuildPoll = ZO_Object:Subclass()



-- EVENT_ADD_ON_LOADED
function GuildPoll:OnAddOnLoaded(event, addonName)
    if (addonName ~= ADDON_NAME) then
        return
    end

    --ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_SCOREBOARD", "Toggle Scoreboard")

    --EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    --EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    --GuildPoll.Settings = GuildPollSettings:New()
    self:Initialize()
end


function GuildPoll:Initialize()
    zo_callLater(function() d("Guild Poll Loaded") end, 2000)

    GuildPoll:ConsoleCommands()
end

function GuildPoll:ConsoleCommands()
    -- Print all available commands to chat
    SLASH_COMMANDS["/gphelp"] = function()
        d("-- Guild Poll commands --")
        d("/gp                      Toggles the guild poll window")
        d("/gp execute              Searches through mail for poll responses")
        d("/gp filter <poll#>       Filters guild roster by players who have responded to that poll")
        d("/gp noresponse <poll#>   Filters guild roster by players who have NOT responded to that poll")
        d("/gp wipe                 Completely WIPES local data")
    end

    SLASH_COMMANDS["/gp"] = function(param)
        local trimmedParam = string.gsub(param, "%s$", ""):lower()
        if(trimmedParam == "") then
            d("[Guild Poll]: Displaying Guild Poll Window")
        elseif (trimmedParam == 'execute') then
            d("[Guild Poll]: Running Mail Search")
        elseif (trimmedParam == 'filter') then
            d("[Guild Poll]: Displaying Users")
        elseif (trimmedParam == 'noresponse') then
            d("[Guild Poll]: Displaying No Responses")
        elseif (trimmedParam == 'wipe') then
            d("[Guild Poll]: Wiping Local Data")
        elseif (trimmedParam == 'help') then
            SLASH_COMMANDS["/gphelp"]()
        else
            d(string.format('Invalid parameter %s.', trimmedParam))
            SLASH_COMMANDS["/gphelp"]()
        end
    end
end

-- Load the addon with this
EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED,
        function(...)
            GuildPoll:OnAddOnLoaded(...)
        end
)
