---@diagnostic disable: undefined-global
---@type string, Addon
local _, addon = ...
addon.WoW.Api = {
    -- constants
    WOW_PROJECT_ID = WOW_PROJECT_ID,
    WOW_PROJECT_CLASSIC = WOW_PROJECT_CLASSIC,
    WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE,
    MAX_RAID_MEMBERS = MAX_RAID_MEMBERS or 40,
    MEMBERS_PER_RAID_GROUP = MEMBERS_PER_RAID_GROUP or 5,

    -- frames
    CreateFrame = CreateFrame,
    UIParent = UIParent,
    CompactPartyFrame = CompactPartyFrame,
    PartyFrame = PartyFrame,
    CompactRaidFrameContainer = CompactRaidFrameContainer,
    CompactArenaFrame = CompactArenaFrame,
    CompactRaidFrameContainer_SetFlowSortFunction = CompactRaidFrameContainer_SetFlowSortFunction,
    CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting,
    EditModeManagerFrame = EditModeManagerFrame,

    -- settings
    SlashCmdList = SlashCmdList,
    SettingsPanel = SettingsPanel,
    InterfaceOptions_AddCategory = InterfaceOptions_AddCategory,
    InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory,
    InterfaceOptionsFramePanelContainer = InterfaceOptionsFramePanelContainer,
    GetCVarBool = GetCVarBool,
    Enum = Enum,
    EventRegistry = EventRegistry,
    Settings = Settings,

    -- macro
    GetMacroInfo = GetMacroInfo,
    EditMacro = EditMacro,

    -- unit functions
    UnitName = UnitName,
    UnitExists = UnitExists,
    UnitIsUnit = UnitIsUnit,
    UnitInRaid = UnitInRaid,
    UnitIsPlayer = UnitIsPlayer,
    GetRaidRosterInfo = GetRaidRosterInfo,
    GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs,
    GetArenaOpponentSpec = GetArenaOpponentSpec,
    GetSpecializationInfoByID = GetSpecializationInfoByID,
    UnitGroupRolesAssigned = UnitGroupRolesAssigned,

    -- state functions
    IsInInstance = IsInInstance,
    IsInGroup = IsInGroup,
    IsInRaid = IsInRaid,
    InCombatLockdown = InCombatLockdown,

    -- utility
    ReloadUI = ReloadUI,
    C_Timer = C_Timer,
    wipe = wipe,
    CopyTable = CopyTable,

    -- secure functions
    issecurevariable = issecurevariable,
    hooksecurefunc = hooksecurefunc,
    RegisterAttributeDriver = RegisterAttributeDriver,

    -- addon related
    GetAddOnEnableState = GetAddOnEnableState,

    -- non-blizzard related
    IsRetail = function()
        return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    end,
    IsWotlk = function()
        return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
    end,
    IsClassic = function()
        return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
    end,

    ---@class WowEvents
    Events = {
        -- Fired after ending combat, as regen rates return to normal.
        -- Useful for determining when a player has left combat.
        -- This occurs when you are not on the hate list of any NPC, or a few seconds after the latest pvp attack that you were involved with.
        -- It seems Blizzard do an update layout after combat ends, so even for the experimental mode we also need to re-sort.
        PLAYER_REGEN_ENABLED = "PLAYER_REGEN_ENABLED",

        -- Fires when the player logs in, /reloads the UI or zones between map instances.
        -- Basically whenever the loading screen appears.
        PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD",

        -- Fired whenever a group or raid is formed or disbanded, players are leaving or joining the group or raid.
        GROUP_ROSTER_UPDATE = "GROUP_ROSTER_UPDATE",

        -- Fired when people within the raid group change their tank/healer/dps role.
        PLAYER_ROLES_ASSIGNED = "PLAYER_ROLES_ASSIGNED",

        -- Fired when a pet is created/destroyed which performs a frame layout.
        UNIT_PET = "UNIT_PET",

        -- Retail only even that's fired at the start of each arena match/round when the opponent specs have been loaded.
        ARENA_PREP_OPPONENT_SPECIALIZATIONS = "ARENA_PREP_OPPONENT_SPECIALIZATIONS",

        ARENA_OPPONENT_UPDATE = "ARENA_OPPONENT_UPDATE",

        -- Special event that's fired when the user closes edit mode.
        -- Can only be used directly on EventRegistry and not via RegisterScript()
        EditModeExit = "EditMode.Exit",
    },
}
