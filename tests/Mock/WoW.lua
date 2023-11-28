local void = require("Mock\\Void")
local frameMock = require("Mock\\Frame")
local timer = require("Mock\\Timer")
---@class WowApiMock: WowApi
local wow = {
    -- mock fields
    State = {
        Frames = {},
        SecureHooks = {},
        AttributeDrivers = {},
        MockInCombat = false,
        Macros = {},
    },

    -- constants
    WOW_PROJECT_ID = "RETAIL",
    WOW_PROJECT_CLASSIC = "CLASSIC",
    WOW_PROJECT_MAINLINE = "RETAIL",
    MAX_RAID_MEMBERS = 40,
    MEMBERS_PER_RAID_GROUP = 5,

    -- frames
    UIParent = frameMock:New("Frame", "UIParent"),
    CompactPartyFrame = frameMock:New("Frame", "CompactPartyFrame"),
    PartyFrame = frameMock:New("Frame", "PartyFrame"),
    CompactRaidFrameContainer = frameMock:New("Frame", "CompactRaidFrameContainer"),
    CompactArenaFrame = frameMock:New("Frame", "CompactArenaFrame"),
    CompactRaidFrameContainer_SetFlowSortFunction = function() end,
    CompactRaidFrameManager_GetSetting = function()
        return nil
    end,
    EditModeManagerFrame = void,
    Settings = void,

    -- settings
    SlashCmdList = void,
    SettingsPanel = {
        Container = {
            GetHeight = function()
                return 500
            end,
            GetWidth = function()
                return 500
            end,
        },
    },
    InterfaceOptions_AddCategory = function() end,
    InterfaceOptionsFrame_OpenToCategory = function() end,
    InterfaceOptionsFramePanelContainer = void,

    GetCVarBool = function()
        return false
    end,
    Enum = {
        EditModeUnitFrameSystemIndices = {
            Party = 1,
            Raid = 2,
        },
        EditModeUnitFrameSetting = {
            RaidGroupDisplayType = 1,
            UseHorizontalGroups = 2,
        },
        EditModeSystem = {
            UnitFrame = 1,
        },
        RaidGroupDisplayType = {
            SeparateGroupsHorizontal = 1,
            SeparateGroupsVertical = 2,
            CombineGroupsHorizontal = 3,
            CombineGroupsVertical = 4,
        },
    },
    EventRegistry = void,

    -- unit functions
    UnitName = function()
        return "Test"
    end,
    UnitExists = function()
        return false
    end,
    UnitIsUnit = function(left, right)
        return left == right
    end,
    UnitInRaid = function()
        return false
    end,
    UnitIsPlayer = function(unit)
        return unit == "player"
    end,
    GetRaidRosterInfo = function()
        local name = "Test"
        local rank = 0
        local subgroup = 1
        local level = 80
        local class = "Test"
        local fileName = "Test"
        local zone = nil
        local online = nil
        local isDead = nil
        local role = "NONE"
        local isML = nil
        local combatRole = "NONE"

        return name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole
    end,
    GetNumArenaOpponentSpecs = function()
        return 0
    end,
    GetArenaOpponentSpec = function()
        local specId = 0
        local gender = 0
        return specId, gender
    end,
    GetSpecializationInfoByID = function()
        local id = 0
        local name = "Test"
        local description = "Test"
        local icon = 0
        local role = "NONE"

        return id, name, description, icon, role
    end,
    UnitGroupRolesAssigned = function()
        return "NONE"
    end,

    -- state functions
    IsInInstance = function()
        return false
    end,
    IsInGroup = function()
        return false
    end,
    IsInRaid = function()
        return false
    end,

    -- utility
    ReloadUI = function() end,
    C_Timer = timer,
    wipe = function(table)
        for key, _ in pairs(table) do
            table[key] = nil
        end

        return table
    end,
    CopyTable = function(table)
        local new = {}

        for key, value in pairs(table) do
            new[key] = value
        end

        return new
    end,

    -- secure functions
    issecurevariable = function()
        return false
    end,

    SecureHandlerWrapScript = function(frame, script, header, preBody, postBody) end,
    SecureHandlerSetFrameRef = function(frame, label, refFrame) end,
    SecureHandlerExecute = function(frame, body) end,

    -- addon related
    GetAddOnEnableState = function()
        return 0
    end,

    -- time related
    GetTimePreciseSec = function()
        return os.time()
    end,

    -- non-blizzard
    IsRetail = function()
        return true
    end,
    IsWotlk = function()
        return false
    end,
    IsClassic = function()
        return false
    end,

    Events = {
        PLAYER_REGEN_ENABLED = "PLAYER_REGEN_ENABLED",
        PLAYER_REGEN_DISABLED = "PLAYER_REGEN_DISABLED",
        PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD",
        GROUP_ROSTER_UPDATE = "GROUP_ROSTER_UPDATE",
        PLAYER_ROLES_ASSIGNED = "PLAYER_ROLES_ASSIGNED",
        UNIT_PET = "UNIT_PET",
        ARENA_PREP_OPPONENT_SPECIALIZATIONS = "ARENA_PREP_OPPONENT_SPECIALIZATIONS",
        ARENA_OPPONENT_UPDATE = "ARENA_OPPONENT_UPDATE",
        EditModeExit = "EditMode.Exit",
    },
}

function wow:Reset()
    self.State.Frames = {}
    self.State.SecureHooks = {}
    self.State.AttributeDrivers = {}
    self.State.Macros = {}
    self.State.MockInCombat = false
    self.UIParent = frameMock:New("Frame", "UIParent")
    self.CompactPartyFrame = frameMock:New("Frame", "CompactPartyFrame")
    self.PartyFrame = frameMock:New("Frame", "PartyFrame")
    self.CompactRaidFrameContainer = frameMock:New("Frame", "CompactRaidFrameContainer")
    self.CompactArenaFrame = frameMock:New("Frame", "CompactArenaFrame")

    timer:Reset()
end

wow.EditModeManagerFrame.editModeActive = false

wow.InCombatLockdown = function()
    return wow.State.MockInCombat
end

wow.UnitIsPlayer = function(unit)
    return not string.match(unit, "*pet*")
end

wow.CreateFrame = function(type, name, parent, template)
    local frame = frameMock:New(type, name, parent, template)
    wow.State.Frames[#wow.State.Frames + 1] = frame

    return frame
end

wow.hooksecurefunc = function(table, name, callback)
    if type(table) == "string" then
        callback = name
        name = table
        table = _G
    end

    wow.State.SecureHooks[#wow.State.SecureHooks + 1] = {
        Table = table,
        Name = name,
        Callback = callback,
    }
end

wow.RegisterAttributeDriver = function(frame, attribute, conditional)
    frame.State.AttributeDrivers[attribute] = {
        Frame = frame,
        Attribute = attribute,
        Conditional = conditional,
    }
end

wow.UnregisterAttributeDriver = function(frame, attribute)
    frame.State.AttributeDrivers[attribute] = nil
end

-- macro
wow.GetMacroInfo = function(id)
    local macro = wow.State.Macros[id]
    if not macro then
        return nil, nil, nil
    end

    macro.TimesRetrieved = macro.TimesRetrieved + 1

    return macro.Name, macro.Icon, macro.Body
end

wow.EditMacro = function(id, name, icon, body)
    local macro = wow.State.Macros[id]
    if not macro then
        macro = {}
        wow.State.Macros[id] = macro
    end

    macro.Id = id
    macro.Name = name
    macro.Icon = icon
    macro.Body = body
    macro.TimesRetrieved = 0

    wow:InvokeSecureHooks("EditMacro", id)

    return id
end

function wow:FireEvent(event, ...)
    assert(#wow.State.Frames > 0, "No frames have been created")

    for _, frame in ipairs(wow.State.Frames) do
        frame:FireEvent(event, ...)
    end
end

function wow:InvokeSecureHooks(name, ...)
    assert(#wow.State.SecureHooks > 0, "No secure hooks have been registered")

    for _, hook in ipairs(wow.State.SecureHooks) do
        if hook.Name == name then
            hook.Callback(...)
        end
    end
end

function wow:LoadMacro(id, name, icon, body)
    wow.State.Macros[id] = {
        Id = id,
        Name = name,
        Icon = icon,
        Body = body,
        TimesRetrieved = 0,
    }
end

return wow
