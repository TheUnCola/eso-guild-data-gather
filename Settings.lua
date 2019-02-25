local ADDON_NAME = "Guild Poll"
local ADDON_VERSION = "0.0.1"

GuildPollSettings = ZO_Object:Subclass()

local LAM2 = LibStub("LibAddonMenu-2.0")
if not LAM2 then return end

--local settings = nil

function GuildPollSettings:New()
    local obj = ZO_Object.New(self)
    self:Initialize()
    return obj
end

function GuildPollSettings:Initialize()
        
    --
    --settings = ZO_SavedVars:New("FarmingPartySettings_db", 2, nil, FarmingPartyDefaults)
    --
    --if not settings.displayOnWindow then FarmingPartyWindow:SetHidden(not settings.displayOnWindow) end
    --local sceneFragment = ZO_HUDFadeSceneFragment:New(FarmingPartyWindow)
    --sceneFragment:SetConditional(function() return settings.displayOnWindow end)
    --HUD_SCENE:AddFragment(sceneFragment)
    --HUD_UI_SCENE:AddFragment(sceneFragment)
    --
    --if settings.displayOnWindow then
    --    self:SetWindowValues()
    --end
    
    local panelData = {
        type = "panel",
        name = ADDON_NAME,
        displayName = ADDON_NAME,
        author = "Aldanga",
        version = ADDON_VERSION,
        slashCommand = "/fp",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    LAM2:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)
    
    LAM2:RegisterOptionControls(ADDON_NAME .. "Panel", optionsTable)
end

--function GuildPollSettings:GetSettings()
--    return settings
--end
