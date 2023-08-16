local void = require("Mock\\Void")
local frameMock = require("Mock\\Frame")
local timer = require("Mock\\Timer")
local wow = {
    -- mock fields
    Frames = {},
    SecureHooks = {},
    AttributeDrivers = {},

    -- constants
    WOW_PROJECT_ID = "RETAIL",
    WOW_PROJECT_CLASSIC = "CLASSIC",
    WOW_PROJECT_MAINLINE = "RETAIL",
    MAX_RAID_MEMBERS = 40,
    MEMBERS_PER_RAID_GROUP = 5,

    -- frames
    UIParent = void,
    CompactPartyFrame = void,
    CompactRaidFrameContainer = void,
    CompactArenaFrame = void,
    CompactRaidFrameContainer_SetFlowSortFunction = function() end,
    CompactRaidFrameManager_GetSetting = function()
        return nil
    end,
    EditModeManagerFrame = void,

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

    -- macro
    GetMacroInfo = function()
        return nil
    end,
    EditMacro = function()
        return 0
    end,

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
    InCombatLockdown = function()
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

    -- addon related
    GetAddOnEnableState = function()
        return 0
    end,
}

wow.CreateFrame = function()
    local frame = {}
    setmetatable(frame, {
        __index = frameMock,
    })

    wow.Frames[#wow.Frames + 1] = frame

    return frame
end

wow.hooksecurefunc = function(table, name, callback)
    if type(table) == "string" then
        table = _G
        name = table
        callback = name
    end

    wow.SecureHooks[#wow.SecureHooks + 1] = {
        Table = table,
        Name = name,
        Callback = callback,
    }
end

wow.RegisterAttributeDriver = function(frame, attribute, conditional)
    wow.AttributeDrivers[#wow.AttributeDrivers + 1] = {
        Frame = frame,
        Attribute = attribute,
        Conditional = conditional,
    }
end

return wow
